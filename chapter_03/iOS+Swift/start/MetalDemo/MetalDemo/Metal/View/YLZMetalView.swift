//
//  YLZMetalView.swift
//  MetalDemo
//
//  Created by Colin on 2018/7/21.
//  Copyright © 2018年 Colin. All rights reserved.
//

import UIKit

class YLZMetalView: UIView {

    var device: MTLDevice?

    var metalLayer: CAMetalLayer {
        return layer as! CAMetalLayer
    }

    override class var layerClass : AnyClass {
        return CAMetalLayer.self
    }

    var commonQueue: MTLCommandQueue?

    var pipelineState: MTLRenderPipelineState?

    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Private
    func commonInit() {

        device = MTLCreateSystemDefaultDevice()
        commonQueue = device?.makeCommandQueue()
        setupPipeline()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        render()
    }

    func setupPipeline() {
        let library = device?.makeDefaultLibrary()!
        let vertexFunction = library?.makeFunction(name: "vertexShader")
        let fragmentFunction = library?.makeFunction(name: "fragmentShader")

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalLayer.pixelFormat

        pipelineState = try! device?.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }

    func render() {
        guard let drawable = metalLayer.nextDrawable() else {
            return
        }

        let renderPassDescriptor = MTLRenderPassDescriptor()
        let colorAttachment = renderPassDescriptor.colorAttachments[0]
        colorAttachment?.clearColor = MTLClearColorMake(0.48, 0.74, 0.92, 1)
        colorAttachment?.texture = drawable.texture  // 渲染目标
        colorAttachment?.loadAction = .clear // 决定前一次 texture 的内容需要清除、还是保留
        colorAttachment?.storeAction = .store // 当 loadAction 是 MTLLoadActionClear 时，则会使用对应的颜色来覆盖当前 texture（用某一色值逐像素写入)

        let commandBuffer = commonQueue?.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)

        guard let pipelineState = pipelineState else { return }
        commandEncoder?.setRenderPipelineState(pipelineState)

        let vertices = [YLZVertex(position: [ 0.5, -0.5], color: [1, 0, 0, 1]),
                        YLZVertex(position: [ 0.5,  0.5], color: [0, 0, 1, 1]),
                        YLZVertex(position: [-0.5, 0.5], color: [0, 1, 0, 1]),
                        YLZVertex(position: [ -0.5,  -0.5], color: [0, 1, 1, 1]),
                        YLZVertex(position: [ 0.5, -0.5], color: [1, 0, 0, 1])]

        commandEncoder?.setVertexBytes(vertices, length: MemoryLayout<YLZVertex>.size * vertices.count, index: Int(YLZVertexInputIndexVertices.rawValue))

        commandEncoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: vertices.count)

        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
