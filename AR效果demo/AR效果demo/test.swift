//
//  test.swift
//  AR效果demo
//
//  Created by 志强 on 2019/6/15.
//  Copyright © 2019 222. All rights reserved.
//

/*
 *概念＃1：屏幕空间与世界空间
 
 *概念＃2：设置成本
 
 *概念＃3：真实世界的背景
 
 *概念＃4：交互模型
 
 *概念＃5：未来
 */
 
 /**
 ARKit从相机中获取新帧。
 我们使用iOS11的Vision Library来检测图像中的矩形。
 如果找到矩形，我们确定它们是否是数独。
 如果我们找到一个拼图，我们将它分成81个方形图像。
 每个方块都通过我们训练的神经网络运行，以确定它代表的是什么数字（如果有的话）。
 收集到足够的数字后，我们使用传统的递归算法来解决难题。
 我们将表示已解决拼图的3D模型传递回ARKit，以显示来自相机的原始图像。
 
 
 
 */



