import UIKit
import Firebase

class PostData: NSObject {
    var id: String?
    var image: UIImage?
    var imageString: String?
    var name: String?
    var caption: String?
    var date: NSDate?
    var likes: [String] = []
    var comments: [String] = []
    var commentUids: [String] = []
    var isLiked: Bool = false
    
    init(snapshot: FDataSnapshot, myId: String) {
        id = snapshot.key
        
        imageString = snapshot.value.objectForKey("image") as? String
        image = UIImage(data: NSData(base64EncodedString: imageString!, options: .IgnoreUnknownCharacters)!)
        
        name = snapshot.value.objectForKey("name") as? String
        caption = snapshot.value.objectForKey("caption") as? String
        
        if let likes = snapshot.value.objectForKey("likes") as? [String] {
            self.likes = likes
        }
        
        for likeId in likes {
            if likeId == myId {
                isLiked = true
                break
            }
        }
        
        if let comments = snapshot.value.objectForKey("comments") as? [String] {
            self.comments = comments
        }
        
        if let commentUids = snapshot.value.objectForKey("commentUids") as? [String] {
            self.commentUids = commentUids
        }
        
        self.date = NSDate(timeIntervalSinceReferenceDate: snapshot.value.objectForKey("time") as! NSTimeInterval)
    }
}
