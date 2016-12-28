//
//  ViewController.m
//  MetalBoilerplate
//
//  Created by Mgen on 28/12/2016.
//  Copyright © 2016 Mgen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    // the Image to be processed
    UIImage *_image;
    // the MTKView used to render all things
    MTKView *_metalView;
    // Non-transient objects
    id<MTLDevice> _device;
    id<MTLCommandQueue> _commandQueue;
    id<MTLLibrary> _library;
    id<MTLBuffer> _vertexBuffer;
    id<MTLComputePipelineState> _computePipelineState;
    MTKTextureLoader *_textureLoader;
    id<MTLTexture> _texture;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    
    // creating MTLDevice and MTKView
    _image = [UIImage imageNamed:@"img.jpeg"];
    scrollView.contentSize = _image.size;
    _device = MTLCreateSystemDefaultDevice();
    _metalView = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, _image.size.width, _image.size.height) device:_device];
    _metalView.device = _device;
    _metalView.delegate = self;
    _metalView.clearColor = MTLClearColorMake(1, 1, 1, 1);
    _metalView.framebufferOnly = NO;
    _metalView.autoResizeDrawable = NO;
    
    // loading texture
    _metalView.drawableSize = _image.size;
    NSError *err = nil;
    _textureLoader = [[MTKTextureLoader alloc] initWithDevice:_device];
    _texture = [_textureLoader newTextureWithCGImage:_image.CGImage options:@{MTKTextureLoaderOptionSRGB: @NO} error:&err];
    NSAssert(!err, [err description]);
    
    // creating command queue and shader functions
    _commandQueue = [_device newCommandQueue];
    _library = [_device newDefaultLibrary];
    id<MTLFunction> computeShader = [_library newFunctionWithName:@"compute_shader"];
    
    // creating compute pipeline state
    _computePipelineState = [_device newComputePipelineStateWithFunction:computeShader error:&err];
    NSAssert(!err, [err description]);
    
    [scrollView addSubview:_metalView];
}

- (void)drawInMTKView:(MTKView *)view {
    // creating command encoder
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    id<MTLTexture> drawingTexture = view.currentDrawable.texture;
    
    // set texture to command encoder
    id<MTLComputeCommandEncoder> encoder = [commandBuffer computeCommandEncoder];
    [encoder setComputePipelineState:_computePipelineState];
    [encoder setTexture:_texture atIndex:0];
    [encoder setTexture:drawingTexture atIndex:1];
    
    // dispatch thread groups
    MTLSize threadGroupCount = MTLSizeMake(16, 16, 1);
    MTLSize threadGroups = MTLSizeMake(drawingTexture.width / threadGroupCount.width, drawingTexture.height / threadGroupCount.height, 1);
    [encoder dispatchThreadgroups:threadGroups threadsPerThreadgroup:threadGroupCount];
    [encoder endEncoding];
    
    // committing the drawing
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
