//
//  ViewController.m
//  MetalBoilerplate
//
//  Created by Mgen on 28/12/2016.
//  Copyright © 2016 Mgen. All rights reserved.
//

#import "ViewController.h"

typedef struct {
    vector_float4 position;
    vector_float4 color;
} VertexInfo;

@interface ViewController ()

@end

@implementation ViewController {
    // the MTKView used to render all things
    MTKView *_metalView;
    // Non-transient objects
    id<MTLCommandQueue> _commandQueue;
    id<MTLLibrary> _library;
    id<MTLBuffer> _vertexBuffer;
    id<MTLBuffer> _indexBuffer;
    id<MTLRenderPipelineState> _renderPipelineState;
    NSUInteger _indexCount;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // creating MTLDevice and MTKView
    id<MTLDevice> device = MTLCreateSystemDefaultDevice();
    _metalView = [[MTKView alloc] initWithFrame:self.view.bounds];
    _metalView.device = device;
    _metalView.delegate = self;
    _metalView.clearColor = MTLClearColorMake(1, 1, 1, 1);
    
    // creating vertex buffer
    VertexInfo vertexInfo[] = {
        {{-0.5, -0.5, 0, 1}, {1, 0, 0, 1}},
        {{0.5, 0.5, 0, 1}, {0, 1, 0, 1}},
        {{-0.5, 0.5, 0, 1}, {0, 0, 1, 1}},
        {{0.5, -0.5, 0, 1}, {1, 1, 0, 1}}
    };
    _vertexBuffer = [device newBufferWithBytes:vertexInfo length:sizeof(vertexInfo) options:MTLResourceOptionCPUCacheModeDefault];
    
    // creating index buffer
    uint16_t indexInfo[] = {2, 1, 0, 0, 3, 1};
    _indexCount = sizeof(indexInfo) / sizeof(uint16_t);
    _indexBuffer = [device newBufferWithBytes:indexInfo length:sizeof(indexInfo) options:MTLResourceOptionCPUCacheModeDefault];
    
    // creating command queue and shader functions
    _commandQueue = [device newCommandQueue];
    _library = [device newDefaultLibrary];
    id<MTLFunction> vertexShader = [_library newFunctionWithName:@"vertex_shader"];
    id<MTLFunction> fragmentShader = [_library newFunctionWithName:@"fragment_shader"];
    
    // creating render pipeline
    MTLRenderPipelineDescriptor *renderPipelineDesc = [MTLRenderPipelineDescriptor new];
    renderPipelineDesc.vertexFunction = vertexShader;
    renderPipelineDesc.fragmentFunction = fragmentShader;
    renderPipelineDesc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    NSError *err = nil;
    _renderPipelineState = [device newRenderPipelineStateWithDescriptor:renderPipelineDesc error:&err];
    NSAssert(!err, [err description]);
    
    [self.view addSubview:_metalView];
}

- (void)drawInMTKView:(MTKView *)view {
    // creating command encoder
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:view.currentRenderPassDescriptor];
    
    // encoding commands
    [commandEncoder setRenderPipelineState:_renderPipelineState];
    [commandEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:0];
    [commandEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:_indexCount indexType:MTLIndexTypeUInt16 indexBuffer:_indexBuffer indexBufferOffset:0];
    [commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    
    // committing the drawing
    [commandEncoder endEncoding];
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
