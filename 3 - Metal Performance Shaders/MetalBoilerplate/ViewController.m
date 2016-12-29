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
    _metalView.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    _metalView.framebufferOnly = NO;
    _metalView.autoResizeDrawable = NO;
    
    // loading texture
    _metalView.drawableSize = _image.size;
    NSError *err = nil;
    _textureLoader = [[MTKTextureLoader alloc] initWithDevice:_device];
    _texture = [_textureLoader newTextureWithCGImage:_image.CGImage options:nil error:&err];
    NSAssert(!err, [err description]);
    
    // creating command queue and shader functions
    _commandQueue = [_device newCommandQueue];
    
    [scrollView addSubview:_metalView];
}

- (void)drawInMTKView:(MTKView *)view {
    // creating command encoder
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    id<MTLTexture> drawingTexture = view.currentDrawable.texture;
    
    // set up and encode the filter
    // MPSImageGaussianBlur *filter = [[MPSImageGaussianBlur alloc] initWithDevice:_device sigma:5];
    MPSImageAreaMax *filter = [[MPSImageAreaMax alloc] initWithDevice:_device kernelWidth:7 kernelHeight:17];
    [filter encodeToCommandBuffer:commandBuffer sourceTexture:_texture destinationTexture:drawingTexture];
    
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
