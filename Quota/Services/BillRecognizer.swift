//
//  BillTextRecognizer.swift
//  Quota
//
//  Created by Marcin Włoczko on 05/01/2019.
//  Copyright © 2019 Marcin Włoczko. All rights reserved.
//

import UIKit
import TesseractOCR

protocol BillRecognizer: class {
    func recognize(from image: UIImage, completion: @escaping ([BillItem]?) -> Void)
}

final class BillRecognizerImp: BillRecognizer {



    func recognize(from image: UIImage, completion: @escaping ([BillItem]?) -> Void) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let tesseract: G8Tesseract = G8Tesseract(language: "language".localized)
            tesseract.pageSegmentationMode = .singleBlock
            tesseract.image = image.g8_blackAndWhite()
            tesseract.recognize()

            let text = tesseract.recognizedText ?? ""
            print(text)
            let items = self?.parseText(text)
            DispatchQueue.main.async {
                completion(items)
            }
        }
    }

    private func parseText(_ text: String) -> [BillItem] {
        var lines = splitLines(string: text)
        lines = removeWrong(lines: lines)
        let billItems = convertToBillItems(lines: lines)
        billItems.forEach { (item) in
            print("\(item.description) \(item.amount)")
        }
        print("suma")
        print(billItems.map{ $0.amount }.reduce(0, { $0 + $1}))
        return billItems
    }

    private func convertToBillItems(lines: [String]) -> [BillItem] {
        var billItems = [BillItem]()

        let amountRegex = try! NSRegularExpression(pattern: "\\d+(,|\\.)\\d{2}", options: [])
        let descriptionRegex = try! NSRegularExpression(pattern: "[\\D]+", options: [.caseInsensitive])

        for line in lines {
            guard let amount = lastMatching(for: amountRegex, in: line).commaToDecimal(),
                let description = firstMatching(for: descriptionRegex, in: line) else {
                    continue
            }
            billItems.append(BillItem(description: description, amount: amount))
        }
        return billItems
    }

    private func splitLines(string: String) -> [String] {
        return string.split(separator: "\n").map(String.init)
    }

    private func removeWrong(lines: [String]) -> [String] {
        let regex = try! NSRegularExpression(pattern: ".*", options: [.caseInsensitive])
        let filteredLines = lines.filter{
            regex.firstMatch(in: $0, options: [], range: NSRange(location: 0, length: $0.count)) != nil
        }
        return filteredLines

    }

    private func lastMatching(for regex: NSRegularExpression, in text: String) -> String? {
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        guard let amountRange = results.last else { return nil }
        return String(text[Range(amountRange.range, in: text)!])
    }

    private func firstMatching(for regex: NSRegularExpression, in text: String) -> String? {
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        guard let amountRange = results.first else { return nil }
        return String(text[Range(amountRange.range, in: text)!])
    }
}
