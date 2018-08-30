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
	static var friends:[Friend] = []

	var name:String = "<Friend>"
	var image:UIImage?
	var details:String = ""

	init(_ name:String = "<Friend>", _ img:UIImage? = nil, _ details:String = "")
	{
		self.name = name
		self.image = img
		self.details = details
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

typealias LinearTransitionProviderVC = LinearTransitionProvider & UIViewController

class FriendListTVC:UITableViewController, LinearTransitionProvider
{

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
}

class FriendDetailVC:UIViewController
{
	var elements:[String:UIView] {
		return ["picture": picture, "nameLabel": nameLabel]
	}
	@IBOutlet weak var picture: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!

}
