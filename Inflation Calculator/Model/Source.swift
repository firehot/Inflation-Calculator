//
//  Source.swift
//  Inflation Calculator
//
//  Created by Cal Stephens on 1/5/18.
//  Copyright © 2018 Cal. All rights reserved.
//

import UIKit

struct Source {
    
    static let sources: [Currency: Source] = [
        .usDollar: Source("US Bureau of Labor Statistics", at: "https://www.bls.gov"),
        .euro: Source("European Central Bank", at: "https://www.ecb.europa.eu/"),
        .britishPound: Source("UK Office for National Statistics", at: "https://www.ons.gov.uk/"),
        .japaneseYen: Source("Statistics Bureau of Japan", at: "http://www.stat.go.jp/english/index.htm"),
        .canadianDollar: Source("Statistics Canada", at: "http://www.statcan.gc.ca/eng/start"),
        .swissFranc: Source("Swiss Federal Statistical Office", at: "https://www.bfs.admin.ch/bfs/en/home.html"),
        .chineseYuan: Source("National Bureau of Statistics of China", at: "http://www.stats.gov.cn/english/"),
        .swedishKrona: Source("Statistics Sweeden", at: "http://www.scb.se/en/"),
        .mexicanPeso: Source("Mexican Institute of Statistics and Geography", at: "http://en.www.inegi.org.mx"),
        .norwegianKrone: Source("Statistics Norway", at: "http://www.ssb.no/en/"),
        .southKoreanWon: Source("Statistics Korea", at: "http://kostat.go.kr/eng/"),
        .turkishLira: Source("Turkish Statistical Institute", at: "http://www.turkstat.gov.tr/"),
        .brazilianReal: Source("Brazilian Institute of Geography and Statistics", at: "https://ww2.ibge.gov.br/english/"),
        .southAfricanRand: Source("Statistics South Africa", at: "http://www.statssa.gov.za"),
        .indianRupee: Source("Labour Bureau, Government of India", at: "http://labourbureaunew.gov.in/"),
        .russianRuble: Source("Russian State Statistics Service", at: "http://www.gks.ru/"),
        .israeliSheqel: Source("Israeli Central Bureau of Statistics", at: "http://www.cbs.gov.il/"),
        .indonesianRupiah: Source("Statistics Indonesia", at: "https://www.bps.go.id")
    ]
    
    static func of(_ currency: Currency) -> Source {
        return sources[currency]!
    }
    
    let name: String
    let urlString: String
    
    var url: URL {
        return URL(string: self.urlString)!
    }
    
    init(_ name: String, at urlString: String) {
        self.name = name
        self.urlString = urlString
    }
    
}
