//
//  SimpleColumnFlowLayout.swift
//  ECleaner
//
//  Created by alexey sorochan on 27.06.2021.
//

import UIKit

class SimpleColumnFlowLayout: UICollectionViewFlowLayout {
    
    var cellsPerRow: Int
    var itemHieght: CGFloat = 100
    
    init(cellsPerRow: Int, minimumInterSpacing: CGFloat, minimumLineSpacing: CGFloat, inset: UIEdgeInsets = .zero) {
        self.cellsPerRow = cellsPerRow
        
        super.init()
        
        self.minimumLineSpacing = minimumLineSpacing
        self.minimumInteritemSpacing = minimumLineSpacing
        self.sectionInset = inset
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        let margInsets = sectionInset.left + sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - margInsets) / CGFloat(cellsPerRow).rounded(.down))
        itemSize = CGSize(width: itemWidth, height: itemHieght)
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}


class CustomCircularCollectionViewLayout: UICollectionViewLayout {
    
    var itemSize = CGSize(width: 200, height: 150)
    var attributesList = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        super.prepare()
        
        
        guard let section = collectionView?.numberOfSections else { return }
        
        for sec in 0...section - 1 {
            
            let itemNo = collectionView?.numberOfItems(inSection: sec) ?? 0
            
            
            let length = (collectionView!.frame.width - 40)/3
            itemSize = CGSize(width: length, height: length)
            
            attributesList = (0..<itemNo).map { (i) -> UICollectionViewLayoutAttributes in
                

                let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: i, section: i))
                
                attributes.size = self.itemSize
                
                var x = CGFloat(i%3)*(itemSize.width+10) + 10
                var y = CGFloat(i/3)*(itemSize.width+10) + 10
                
                if i > 2 {
                    y += (itemSize.width+10)
                    attributes.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
                } else if i == 0 {
                    attributes.frame = CGRect(x: x, y: y, width: itemSize.width*2+10, height: itemSize.height*2+10)
                } else {
                    x = itemSize.width*2 + 30
                    if i == 2 {
                        y += itemSize.height + 10
                    }
                    attributes.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
                }
                debugPrint(attributes)
                debugPrint(attributesList)
            return attributes
               
            }
        }
    }
        
    
    override var collectionViewContentSize : CGSize {
        
        guard let section = collectionView?.numberOfSections else { return CGSize.zero}

        for sec in 0...section - 1 {
        
        return CGSize(width: collectionView!.bounds.width, height: (itemSize.height + 10)*CGFloat(ceil(Double(collectionView!.numberOfItems(inSection: sec))/3))+(itemSize.height + 20))
        }
        
        return CGSize.zero
        
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesList
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section < attributesList.count
        {
            return attributesList[indexPath.section]
        }
        
//        if let index = indexPath(sec)
        return nil
//        return attributesList[indexPath(
        
      
        
    
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

class GridCollectionViewLayout: UICollectionViewLayout {

var itemSize = CGSize(width: 200, height: 150)
var attributesList = [UICollectionViewLayoutAttributes]()

override func prepare() {
    super.prepare()
    
    
    
    
    
//        .compactMap { tableView.indexPath(for: $0) }
//            .filter { $0.section == SECTION }

    let itemNo = collectionView?.numberOfItems(inSection: 0) ?? 0
    let length = (collectionView!.frame.width - 40)/3
    itemSize = CGSize(width: length, height: length)
    
//        .compactMap { tableView.indexPath(for: $0) }
//            .filter { $0.section == SECTION }
    
    
    attributesList =  (0..<itemNo).map { (i) -> UICollectionViewLayoutAttributes in
        let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))

        attributes.size = self.itemSize

        var x = CGFloat(i%3)*(itemSize.width+10) + 10
        var y = CGFloat(i/3)*(itemSize.width+10) + 10

        if i > 2 {
            y += (itemSize.width+10)
            attributes.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
        } else if i == 0 {
            attributes.frame = CGRect(x: x, y: y, width: itemSize.width*2+10, height: itemSize.height*2+10)
        } else {
            x = itemSize.width*2 + 30
            if i == 2 {
                y += itemSize.height + 10
            }
            attributes.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
        }

        return attributes
    }
}

override var collectionViewContentSize : CGSize {

    return CGSize(width: collectionView!.bounds.width, height: (itemSize.height + 10)*CGFloat(ceil(Double(collectionView!.numberOfItems(inSection: 0))/3))+(itemSize.height + 20))

}

override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return attributesList
}
override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    if indexPath.row < attributesList.count
    {
        return attributesList[indexPath.row]
    }
    return nil
}
override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
}
}

protocol FillingLayoutDelegate: class {
    func collectionView(_ collectionView:UICollectionView, sizeForViewAtIndexPath indexPath:IndexPath) -> Int
    //  Returns the amount of columns that have to display at that moment
    func numberOfColumnsInCollectionView(collectionView:UICollectionView) ->Int
}

class FillingLayout: UICollectionViewLayout {
    weak var delegate: FillingLayoutDelegate!

    fileprivate var cellPadding: CGFloat = 10

    fileprivate var cache = [UICollectionViewLayoutAttributes]()

    fileprivate var contentHeight: CGFloat = 0
    private var columsHeights : [CGFloat] = []
    private var avaiableSpaces : [(Int,CGFloat)] = []

    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    var columnsQuantity : Int{
        get{
            if(self.delegate != nil)
            {
                return (self.delegate?.numberOfColumnsInCollectionView(collectionView: self.collectionView!))!
            }
            return 0
        }
    }

    //MARK: PRIVATE METHODS
    private func shortestColumnIndex() -> Int{
        var retVal : Int = 0
        var shortestValue = MAXFLOAT

        var i = 0
        for columnHeight in columsHeights {
            //debugPrint("Column Height: \(columnHeight) index: \(i)")
            if(Float(columnHeight) < shortestValue)
            {
                shortestValue = Float(columnHeight)
                retVal = i
            }
            i += 1
        }
        //debugPrint("shortest Column index: \(retVal)")
        return retVal
    }

    //MARK: PRIVATE METHODS
    private func largestColumnIndex() -> Int{
        var retVal : Int = 0
        var largestValue : Float = 0.0

        var i = 0
        for columnHeight in columsHeights {
            //debugPrint("Column Height: \(columnHeight) index: \(i)")
            if(Float(columnHeight) > largestValue)
            {
                largestValue = Float(columnHeight)
                retVal = i
            }
            i += 1
        }
        //debugPrint("shortest Column index: \(retVal)")
        return retVal
    }

    private func canUseBigColumnOnIndex(columnIndex:Int,size:Int) ->Bool
    {
        if(columnIndex < self.columnsQuantity - (size-1))
        {
            let firstColumnHeight = columsHeights[columnIndex]
            for i in columnIndex..<columnIndex + size{
                if(firstColumnHeight != columsHeights[i]) {
                    return false
                }
            }
            return true
        }

        return false
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        // Check if cache is empty
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }

        //  Set all column heights to 0
        self.columsHeights = []
        for _ in 0..<self.columnsQuantity {
            self.columsHeights.append(0)
        }
        
        for section in 0 ..< collectionView.numberOfSections - 1 {
        

        for item in 0 ..< collectionView.numberOfItems(inSection: section) {

            let indexPath = IndexPath(item: item, section: section)

            let viewSize: Int = delegate.collectionView(collectionView, sizeForViewAtIndexPath: indexPath)
            let blockWidth = (contentWidth/CGFloat(columnsQuantity))
            let width = blockWidth * CGFloat(viewSize)
            let height = width

            var columIndex = self.shortestColumnIndex()
            var xOffset = (contentWidth/CGFloat(columnsQuantity)) * CGFloat(columIndex)
            var yOffset = self.columsHeights[columIndex]

            if(viewSize > 1){//Big Cell
                if(!self.canUseBigColumnOnIndex(columnIndex: columIndex,size: viewSize)){
                    //  Set column height
                    for i in columIndex..<columIndex + viewSize{
                        if(i < columnsQuantity){
                            self.avaiableSpaces.append((i,yOffset))
                            self.columsHeights[i] += blockWidth
                        }
                    }
                    //  Set column height
                    yOffset = columsHeights[largestColumnIndex()]
                    xOffset = 0
                    columIndex = 0
                }

                for i in columIndex..<columIndex + viewSize{
                    if(i < columnsQuantity){
                        //current height
                        let currValue = self.columsHeights[i]
                        //new column height with the update
                        let newValue = yOffset + height
                        //space that will remaing in blank, this must be 0 if its ok
                        let remainder = (newValue - currValue) - CGFloat(viewSize) * blockWidth
                        if(remainder > 0) {
                            debugPrint("Its bigger remainder is \(remainder)")
                            //number of spaces to fill
                            let spacesTofillInColumn = Int(remainder/blockWidth)
                            //we need to add those spaces as avaiableSpaces
                            for j in 0..<spacesTofillInColumn {
                                self.avaiableSpaces.append((i,currValue + (CGFloat(j)*blockWidth)))
                            }
                        }
                        self.columsHeights[i] = yOffset + height
                    }
                }
            }else{
                //if there is not avaiable space
                if(self.avaiableSpaces.count == 0)
                {
                    //  Set column height
                    self.columsHeights[columIndex] += height
                }else{//if there is some avaiable space
                    yOffset = self.avaiableSpaces.first!.1
                    xOffset = CGFloat(self.avaiableSpaces.first!.0) * width
                    self.avaiableSpaces.remove(at: 0)
                }
            }

            print(width)

            let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)

            contentHeight = max(contentHeight, frame.maxY)
        }
    }
    }

    func getNextCellSize(currentCell: Int, collectionView: UICollectionView) -> Int {
        var nextViewSize = 0
        if currentCell < (collectionView.numberOfItems(inSection: 0) - 1) {
            nextViewSize = delegate.collectionView(collectionView, sizeForViewAtIndexPath: IndexPath(item: currentCell + 1, section: 0))
        }
        return nextViewSize
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
