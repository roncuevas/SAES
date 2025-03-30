/*
 import Foundation

 struct GPTResponseModel: Codable {
 let id, object: String?
 let created: Int?
 let model: String?
 let choices: [Choice]?
 let usage: Usage?
 let systemFingerprint: String?

 enum CodingKeys: String, CodingKey {
 case id, object, created, model, choices, usage
 case systemFingerprint = "system_fingerprint"
 }
 }

 // MARK: - Choice
 struct Choice: Codable {
 let index: Int?
 let message: Message?
 let logprobs: String?
 let finishReason: String?

 enum CodingKeys: String, CodingKey {
 case index, message, logprobs
 case finishReason = "finish_reason"
 }
 }

 // MARK: - Message
 struct Message: Codable {
 let role, content: String?
 }

 // MARK: - Usage
 struct Usage: Codable {
 let promptTokens, completionTokens, totalTokens: Int?

 enum CodingKeys: String, CodingKey {
 case promptTokens = "prompt_tokens"
 case completionTokens = "completion_tokens"
 case totalTokens = "total_tokens"
 }
 }
 */
