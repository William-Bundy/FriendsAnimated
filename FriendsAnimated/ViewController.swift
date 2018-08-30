//
//  ViewController.swift
//  FriendsAnimated
//
//  Created by William Bundy on 8/30/18.
//  Copyright © 2018 William Bundy. All rights reserved.
//

import UIKit


class Friend
{
	static let boy = "guy_face"
	static let girl = "girl_face"
	static let cannedDetails:[String] = [
		"Secretly has a shrine to Steve Jobs in the attic",
		"Likes to sleep a lot",
		"Passes tests without studying",
		"Prefers Android to iOS",
		"Prefers iOS to Android",
		"Wishes they were taller",
		"Always wears sunglasses outside",
		"Has a birthday on a major holiday",
		"Once climbed a tree and had to call the fire dept to get out",
		"Decided to shave their head once--it was weird",
		"Always wants to donate to charity marathons",
		"Plays clarinet",
		"Plays trombone",
		"Plays saxophone",
		"Plays trumpet",
		"Plays flute",
		"Plays piano",
	]
	static var friends:[Friend] = [Friend("Dillon", boy), Friend("Taylor", boy), Friend("Alex", boy),
								   Friend("Summer", girl), Friend("Megan", girl), Friend("Lennie", girl)]

	var name:String = "<Friend>"
	var image:UIImage?
	var details:String = ""

	init(_ name:String = "<Friend>", _ img:String? = nil, _ details:String? = nil)
	{
		self.name = name
		if let img = img {
			self.image = UIImage(named:img)
		}
		if let details = details {
			self.details = details
		} else {
			self.details = Friend.cannedDetails[Int(arc4random_uniform(UINT32_MAX)) % Friend.cannedDetails.count]
		}
	}
}

class FriendCell:UITableViewCell
{
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var picture: UIImageView!

	var friend:Friend! {
		didSet {
			nameLabel.text = friend.name
			if let img = friend.image {
				picture.image = img
			}
		}
	}

	var elements:[String:UIView] {
		return ["picture":picture, "nameLabel":nameLabel]
	}
}

protocol LinearTransitionProvider
{
	var elements:[String:UIView] { get }

}

func elementUnion(_ a:LinearTransitionProviderVC, _ b:LinearTransitionProvider) -> [(from:UIView, to:UIView)]
{
	var views:[(from:UIView, to:UIView)] = []
	for key in a.elements.keys {
		if b.elements[key] != nil {
			views.append((from:a.elements[key]!, to:b.elements[key]!))
		}
	}
	return views
}

typealias LinearTransitionProviderVC = LinearTransitionProvider & UIViewController

class FriendListTVC:UITableViewController, LinearTransitionProvider, UINavigationControllerDelegate
{

	override func viewDidLoad() {
		navigationController?.delegate = self
	}
	var elements: [String : UIView] {
		if let path = tableView.indexPathForSelectedRow {
			let defaultCell = tableView.cellForRow(at: path)
			guard let cell = defaultCell as? FriendCell else {return [:]}
			return cell.elements

		}
		return [:]
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return Friend.friends.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let defaultCell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)

		guard let cell = defaultCell as? FriendCell else { return defaultCell }

		cell.friend = Friend.friends[indexPath.row]

		return defaultCell
	}

	let animator = LinearAnimator()

	/*
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return animator
	}
*/
	func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return animator
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let dest = segue.destination as? FriendDetailVC {
			dest.friend = Friend.friends[tableView.indexPathForSelectedRow?.row ?? 0]
		}
	//	segue.destination.transitioningDelegate = self
	}

}

class FriendDetailVC:UIViewController, LinearTransitionProvider
{
	var elements:[String:UIView] {
		return ["picture": picture, "nameLabel": nameLabel]
	}
	@IBOutlet weak var picture: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
	var friend:Friend!

	override func viewWillAppear(_ animated: Bool) {
		picture.image = friend.image
		nameLabel.text = friend.name
		detailLabel.text = friend.details
	}
}

extension UIView
{
	func clone() -> UIView
	{
		// pretend this works:
		//return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! UIView
		if let label = self as? UILabel {
			let new = UILabel(frame: self.frame)
			new.text = label.text
			new.font = label.font
			return new
		} else if let iv = self as? UIImageView {
			let new = UIImageView(frame: self.frame)
			new.image = iv.image
			new.contentMode = self.contentMode
			return new
		}
		print("Unsupported clone")
		return UIView()
	}
}
class LinearAnimator:NSObject, UIViewControllerAnimatedTransitioning
{
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 1.0
	}

	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		print("animate entered")
		guard let toVC = transitionContext.viewController(forKey: .to) as? LinearTransitionProviderVC,
		let fromVC = transitionContext.viewController(forKey: .from) as? LinearTransitionProviderVC,
			let toView = transitionContext.view(forKey: .to) else {print("to/from wasn't LTP"); return}
		print("guard passed")

		let container = transitionContext.containerView

		let movingParts = elementUnion(fromVC, toVC)
		var animated:[UIView] = []
		for part in movingParts {
			print("clone made")
			let clone = part.from.clone()
			clone.frame = container.convert(part.from.bounds, from: part.from)
			container.addSubview(clone)
			animated.append(clone)

			part.from.alpha = 0
			part.to.alpha = 0
		}

		toView.layoutIfNeeded()

		print("animate started")
		UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
			for i in 0..<movingParts.count {
				let part = movingParts[i]
				animated[i].frame = container.convert(part.to.bounds, from: part.to)
			}

		}) { success in
			for i in 0..<movingParts.count {
				animated[i].removeFromSuperview()

				let part = movingParts[i]
				part.to.alpha = 1
				part.from.alpha = 1
			}

			transitionContext.completeTransition(success)
			container.addSubview(toView)
		}
	}

}
