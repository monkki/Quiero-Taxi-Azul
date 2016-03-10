//
//  AyudaViewController.swift
//  Quiero Taxi
//
//  Created by Roberto Gutierrez on 09/11/15.
//  Copyright © 2015 Roberto Gutierrez. All rights reserved.
//

import UIKit

class AyudaViewController: UIViewController, UIPageViewControllerDataSource {
    
    var pageViewController: UIPageViewController?
    var pageImages: [String] = ["ayuda1.png", "ayuda2.png"]
    var currentIndex: Int = 0

    @IBOutlet var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = "revealToggle:"
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController!.dataSource = self
        
        let startingViewController: Paginado = viewControllerAtIndex(0)!
        let viewControllers: NSArray = [startingViewController]
        pageViewController!.setViewControllers(viewControllers as! [UIPageViewController], direction: .Forward, animated: false, completion: nil)
        pageViewController!.view.frame = CGRectMake(-5, 50, view.frame.size.width , view.frame.size.height);
        
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
        
        // Imagen encabezado
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 160, height: 40))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "quieroTaxiEncabezado")
        imageView.image = image
        navigationItem.titleView = imageView
        navigationItem.titleView!.sizeThatFits(CGSize(width: 220, height: 65))

    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! Paginado).pageIndex
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! Paginado).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        
        if (index == self.pageImages.count) {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> Paginado? {
        
        if self.pageImages.count == 0 || index >= self.pageImages.count {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let pageContentViewController = Paginado()
        pageContentViewController.imageFile = pageImages[index]
        pageContentViewController.pageIndex = index
        currentIndex = index
        
        return pageContentViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageImages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
