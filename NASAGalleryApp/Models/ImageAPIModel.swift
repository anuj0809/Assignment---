

import Foundation

struct ImageAPIModel: Codable, Hashable {
    
    var copyright: String?
    var date: String?
    var explanation: String?
    var hdURL: URL?
    var mediaType: String?
    var serviceVersion: String?
    var title: String?
    var url: URL?
    
    enum CodingKeys: String, CodingKey {
        
        case copyright, date, explanation, title, url
        case hdURL = "hdurl"
        case serviceVersion = "service_version"
        case mediaType = "media_type"
    }
}
