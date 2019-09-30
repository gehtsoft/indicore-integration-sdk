import UIKit

class ViewController: UITableViewController
{
    private var loadedIndicators = [IndicoreIndicatorProfile]()
    private var manager: IndicoreManager?
    private var host: IndicoreHost?
    private let detailedTextColor = UIColor(displayP3Red: 105/255.0, green: 67/255.0, blue: 169/255.0, alpha: 1)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "Indicators"
        
        do
        {
            try loadStdIndicators()
        }
        catch
        {
            informUserAboutFinishing(text: "Cannot load indicators!")
        }
    }
    
    
    func loadStdIndicators() throws
    {
        let indicatorsPath = Bundle.main.bundlePath + "/StandardIndicators";
        let fsmp = IndicoreFileSystemMetadataProvider(language: IndicoreLanguage.eIndicoreLanguageLua, type: IndicoreType.eIndicoreTypeIndicator)
        let fileAccessor = try IndicoreFileSystemAccessor(indicatorsPath: indicatorsPath, fsmp: fsmp)
        let mask = ["*.lua"]
        let fileEnumerator = try fileAccessor.enumerator(indicatorsPath, mask: mask, recursive: false)
        manager = IndicoreManager.createInstance(nil)
        let domain = manager?.createDomain(withId: "main", name: "main domain")
        host = HostTest()
        let metadata = IndicoreLoadMetadata(host: host!)
        try manager?.loadIntoDomain(withId: domain!, accessor: fileAccessor, enumerator: fileEnumerator, metadata: metadata!)
        let profiles = manager?.indicatorProfiles(for: domain!)
        let indicatorsCount = profiles!.size()
        
        for index in 0..<indicatorsCount
        {
            let indicator = profiles?.profile(at: index)
            loadedIndicators.append(indicator!)
        }
        
        self.tableView.reloadData();
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return loadedIndicators.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        if indexPath.row < loadedIndicators.count
        {
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            let profile = loadedIndicators[indexPath.row]
            let mainInfoText = "\(profile.name()!) (\(profile.identifier()!))"
            let detailedTextInfo = "Type: \(parseType(profile: profile)), required source: \(parseSource(profile: profile))"
            cell.textLabel?.text = mainInfoText
            cell.detailTextLabel?.text = detailedTextInfo
            cell.detailTextLabel?.textColor = detailedTextColor
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.row >= loadedIndicators.count
        {
            return
        }
    
        let detailViewController = storyboard?.instantiateViewController(withIdentifier: "PropertyViewController") as! PropertyViewController;
        detailViewController.indicatorProfile = loadedIndicators[indexPath.row]
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func parseType(profile: IndicoreIndicatorProfile) -> String
    {
        let type = profile.indicatorType()
        switch type
        {
        case .eIndicoreIndicator:
            return "indicator"
        case .eIndicoreOscillator:
            return "oscillator"
        case .eIndicoreView:
            return "view"
        }
    }
    
    func parseSource(profile: IndicoreIndicatorProfile) -> String
    {
        let source = profile.requiredSource()
        switch source
        {
        case .eIndicoreTickSource:
            return "tiks"
        case .eIndicoreBarSource:
            return "bars"
        case .eIndicoreUnknownSource:
            return "unknown"
        }
    }
    
    func informUserAboutFinishing(text: String)
    {
        let alert = UIAlertView()
        alert.message = text
        alert.addButton(withTitle: "OK")
        alert.show()
    }
}















