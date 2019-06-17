//
//  ARTestViewController.swift
//  AR效果demo
//
//  Created by 志强 on 2019/6/14.
//  Copyright © 2019 222. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MapKit
import CoreLocation
import GLKit.GLKMatrix4

/*
 *https://medium.com/journey-of-one-thousand-apps/arkit-and-corelocation-part-two-7b045fb1d7a1
 *创建旋转变换以使节点朝向正确的方向
 
 *半正矢
 *Haversine公式的一个缺点是它可能在较长距离内变得不太准确。如果我们为商用客机设计可能存在问题的导航系统，但距离不足以对ARKit演示产生影响。
 
 *翻译矩阵
 *旋转和缩放变换矩阵仅需要三列。但是，为了进行翻译，矩阵需要至少有四列。这就是转换通常是4x4矩阵的原因。然而，由于矩阵乘法的规则，具有四列的矩阵不能与3D矢量相乘。四列矩阵只能乘以四元素向量，这就是我们经常使用齐次4D向量而不是3D向量的原因
 
 *结合矩阵变换
 组合转换的顺序非常重要。组合转换时，应按以下顺序进行：变换 = 缩放 * 旋转 * 翻译(translation)
 
 *SIMD（单指令多数据）
 *输入simd.h：这个内置库为我们提供了一个标准接口，用于在OS X和iOS上的各种处理器上处理2D，3D和4D矢量和矩阵运算。如果CPU本身不支持给定的操作（例如将4通道向量分成两个双通道操作），它会自动回退到软件例程。它还具有使用Metal在GPU和CPU之间轻松传输数据的好处。
 SIMD是一种跨越GPU着色器和老式CPU指令之间差距的技术，允许CPU发出单个指令来并行处理数据块
 - www.russbishop.net
 
 simd_mul按从右到左的顺序执行操作
 
 */

class MatrixHelper {
    
    //    column 0  column 1  column 2  column 3
    //         1        0         0       X          x        x + X*w 
    //         0        1         0       Y      x   y    =   y + Y*w 
    //         0        0         1       Z          z        z + Z*w 
    //         0        0         0       1          w           w    
    
    static func translationMatrix(with matrix: matrix_float4x4, for translation : vector_float4) -> matrix_float4x4 {
        var matrix = matrix
        matrix.columns.3 = translation
        return matrix
    }
    
    //    column 0  column 1  column 2  column 3
    //        cosθ      0       sinθ      0    
    //         0        1         0       0    
    //       −sinθ      0       cosθ      0    
    //         0        0         0       1    
    
    static func rotateAroundY(with matrix: matrix_float4x4, for degrees: Float) -> matrix_float4x4 {
        var matrix : matrix_float4x4 = matrix
        
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)
        
        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }
    
    static func transformMatrix(for matrix: simd_float4x4, originLocation: CLLocation, location: CLLocation) -> simd_float4x4 {
        let distance = Float(location.distance(from: originLocation))
        let bearing = GLKMathDegreesToRadians(Float(originLocation.coordinate.direction(to: location.coordinate)))
        let position = vector_float4(0.0, 0.0, -distance, 0.0)
        let translationMatrix = MatrixHelper.translationMatrix(with: matrix_identity_float4x4, for: position)
        let rotationMatrix = MatrixHelper.rotateAroundY(with: matrix_identity_float4x4, for: bearing)
        let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
        return simd_mul(matrix, transformMatrix)
    }
}

//class MatrixHelper {
//
//    //    column 0  column 1  column 2  column 3
//    //         1        0         0       X          x        x + X*w 
//    //         0        1         0       Y      x   y    =   y + Y*w 
//    //         0        0         1       Z          z        z + Z*w 
//    //         0        0         0       1          w           w    
//
//    static func translationMatrix(translation : vector_float4) -> matrix_float4x4 {
//        var matrix = matrix_identity_float4x4
//        matrix.columns.3 = translation
//        return matrix
//    }
//}
//class MatrixHelper {
//
//    //    column 0  column 1  column 2  column 3
//    //        cosθ      0       sinθ      0    
//    //         0        1         0       0    
//    //       −sinθ      0       cosθ      0    
//    //         0        0         0       1    
//
//
//    static func rotateAroundY(with matrix: matrix_float4x4, for degrees: Float) -> matrix_float4x4 {
//        var matrix : matrix_float4x4 = matrix
//
//        matrix.columns.0.x = cos(degrees)
//        matrix.columns.0.z = -sin(degrees)
//
//        matrix.columns.2.x = sin(degrees)
//        matrix.columns.2.z = cos(degrees)
//        return matrix.inverse
//    }
//}

extension CLLocationCoordinate2D {
    func calculateBearing(to coordinate: CLLocationCoordinate2D) -> Double {
        let a = sin(coordinate.longitude.toRadians() - longitude.toRadians()) * cos(coordinate.latitude.toRadians())
        let b = cos(latitude.toRadians()) * sin(coordinate.latitude.toRadians()) - sin(latitude.toRadians()) * cos(coordinate.latitude.toRadians()) * cos(coordinate.longitude.toRadians() - longitude.toRadians())
        return atan2(a, b)
    }
    
    func direction(to coordinate: CLLocationCoordinate2D) -> CLLocationDirection {
        return self.calculateBearing(to: coordinate).toDegrees()
    }
}

extension Double {
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
    
    func toDegrees() -> Double {
        return self * 180.0 / .pi
    }
}

class ARTestViewController: UIViewController,ARSCNViewDelegate {
    
    var sceneView : ARSCNView!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        sceneView = ARSCNView(frame: self.view.frame)
        sceneView.delegate = self
        sceneView.showsStatistics = true
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        sceneView.scene = scene
        self.view.addSubview(sceneView)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneView.scene.rootNode.childNodes[0].transform = SCNMatrix4Mult(sceneView.scene.rootNode.childNodes[0].transform, SCNMatrix4MakeRotation(Float(Double.pi) / 2, 1, 0, 0))
        sceneView.scene.rootNode.childNodes[0].transform = SCNMatrix4Mult(sceneView.scene.rootNode.childNodes[0].transform, SCNMatrix4MakeTranslation(0, 0, -2))
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
//
//struct NavigationService {
//
//    func getDirections(destinationLocation: CLLocationCoordinate2D, request: MKDirectionsRequest, completion: @escaping ([MKRouteStep]) -> Void) {
//        var steps: [MKRouteStep] = []
//
//        let placeMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destinationLocation.coordinate.latitude, longitude: destinationLocation.coordinate.longitude))
//
//        request.destination = MKMapItem.init(placemark: placeMark)
//        request.source = MKMapItem.forCurrentLocation()
//        request.requestsAlternateRoutes = false
//        request.transportType = .walking
//
//
//
//let directions = MKDirections(request: request)
//
//directions.calculate { response, error in
//    if error != nil {
//        print("Error getting directions")
//    } else {
//        guard let response = response else { return }
//        for route in response.routes {
//            steps.append(contentsOf: route.steps)
//        }
//        completion(steps)
//    }
//}
//}
//}
