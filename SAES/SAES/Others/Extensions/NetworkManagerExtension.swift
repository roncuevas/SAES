/*
import Alamofire
import Foundation

extension NetworkManager {
    static func getURL() -> String {
        return "https://api.openai.com/v1/chat/completions"
    }

    static func getKardexHeadersRequest() -> HTTPHeaders {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer ",
            "Host": "api.openai.com",
            "Accept-Encoding": "gzip, deflate, br",
            "Connection": "keep-alive"
        ]
    }
    
    static func getKardexBodyRequest(from kardexText: String) -> [String: Any] {
        return [
            "messages": [
                [
                    "content": [
                        [
                            "type": "text",
                            // swiftlint:disable:next line_length
                            "text": "Give me a compressed JSON object like the following format and do not reply\n\n{\"escuela\":\"ESCUELA NACIONAL DE MEDICINA Y HOMEOPATÍA\",\"boleta\":\"2019520230\",\"nombre\":\"AARON ALBERTO MARTINEZ CUEVAS\",\"carrera\":\"MEDICO CIRUJANO Y PARTERO\",\"plan\":\"04\",\"promedio\":\"8.75\",\"kardex\":[{\"semestre\":\"PRIMER SEMESTRE\",\"materias\":[{\"clave\":\"P101\",\"materia\":\"ANATOMIA HUMANA I\",\"fecha\":\"Jun 28 2019\",\"periodo\":\"19/2\",\"forma_eval\":\"ORD\",\"calificacion\":\"9\"}]}]}"
                        ]
                    ],
                    "role": "system"
                ],
                [
                    "content": [
                        [
                            "type": "text",
                            "text": "\(kardexText)"
                        ]
                    ],
                    "role": "user"
                ]
            ],
            "frequency_penalty": 0,
            "response_format": [ "type": "json_object" ],
            "model": "gpt-4o-mini-2024-07-18",
            "temperature": 1,
            "presence_penalty": 0,
            "max_tokens": 16383,
            "top_p": 1
        ]
    }
}
*/
