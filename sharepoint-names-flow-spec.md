# Power Automate Flow: SharePoint Process Owners & Managers Extractor

## Overview
This flow automatically extracts Process Owner and Process Manager information from multiple SharePoint sites and maintains an updated Excel file with this data.

## Flow Requirements

### Schedule
- **Frequency**: Once per night (recommended: 2:00 AM)
- **Trigger Type**: Recurrence

### Data Sources
- Multiple SharePoint sites (to be configured)
- Fields to extract:
  - Process Owner / Process Owners
  - Process Manager / Process Managers
  - Variations: `[ProcessName] Process Owner(s)` or `[ProcessName] Process Manager(s)`
  - Examples: "Problem Process Owners", "SITS Process Managers"

### Output
- Excel file stored in SharePoint or OneDrive
- Columns: Site Name, Process Name, Field Type (Owner/Manager), Person Name, Email, Last Updated

---

## Flow Design

### Step 1: Initialize Variables
Create the following variables at the start of the flow:

```
- SharePointSites (Array): List of SharePoint site URLs
- ExcelFileLocation (String): Path to Excel file
- ExcelTableName (String): Name of Excel table
- ProcessData (Array): Temporary storage for extracted data
```

### Step 2: Loop Through SharePoint Sites

For each SharePoint site in your list:

#### 2.1: Get Site Pages/Lists
- **Action**: Send an HTTP request to SharePoint
- **Method**: GET
- **URI**: `_api/web/lists`
- **Headers**: Accept: application/json;odata=verbose

#### 2.2: Identify Target Lists/Libraries
Look for lists/libraries that contain your process information:
- Document libraries
- Custom lists
- Pages library

#### 2.3: Get List Items
- **Action**: Get items (SharePoint)
- **Site Address**: Current site URL
- **List Name**: Identified list
- **Filter Query**: Include only items with relevant columns

### Step 3: Extract Person Field Data

For each item found:

#### 3.1: Parse Column Names
Use **Compose** actions to create patterns for field matching:
```
Pattern examples:
- *Process Owner*
- *Process Owners*
- *Process Manager*
- *Process Managers*
```

#### 3.2: Extract People Picker Values
For each matching field:
- **Get Person Information**: Extract name, email from people picker field
- **Parse JSON**: Extract user details
  ```json
  {
    "DisplayName": "@{items('Apply_to_each')?['ProcessOwner']?['DisplayName']}",
    "Email": "@{items('Apply_to_each')?['ProcessOwner']?['Email']}"
  }
  ```

### Step 4: Transform Data

Create structured records with:
- Site Name
- Process Name (extracted from field name prefix)
- Field Type (Owner or Manager)
- Person Display Name
- Person Email
- Timestamp

**Example Transformation**:
```
Input: "SITS Process Managers" = John Doe
Output:
  - Site: "Finance SharePoint"
  - Process: "SITS"
  - Type: "Manager"
  - Name: "John Doe"
  - Email: "john.doe@company.com"
  - Last Updated: "2026-01-09T02:00:00Z"
```

### Step 5: Update Excel File

#### 5.1: Check if Excel File Exists
- **Action**: Get file metadata
- **If not exists**: Create new Excel file with headers

#### 5.2: Get Existing Rows
- **Action**: List rows present in a table
- **Location**: OneDrive/SharePoint
- **File**: Your Excel file
- **Table**: ProcessOwnersTable

#### 5.3: Compare and Update
For each extracted record:

**Condition 1**: Check if record exists (match on Site + Process + Type + Name)
- **If YES**:
  - Check if data changed
  - If changed: Update row with new timestamp
  - If unchanged: Skip
- **If NO**:
  - Add new row to table

#### 5.4: Add New Rows
- **Action**: Add a row into a table
- **Location**: OneDrive/SharePoint
- **File**: Your Excel file
- **Table**: ProcessOwnersTable
- **Row Data**: Map extracted fields to columns

#### 5.5: Handle Deletions (Optional)
- Compare existing Excel rows with extracted data
- Mark or remove rows that no longer exist in SharePoint

### Step 6: Error Handling

Wrap each site processing in a **Scope** action with error handling:
- **Configure run after**: Add parallel branch for failure
- **Action on failure**: Send notification email
- **Log errors**: Append to error log table/list

### Step 7: Send Summary Report (Optional)

After all sites processed:
- **Action**: Send an email
- **To**: Your email
- **Subject**: "SharePoint Process Owners Update - [Date]"
- **Body**:
  ```
  - Sites Processed: X
  - Records Updated: X
  - New Records Added: X
  - Errors: X
  ```

---

## Excel File Structure

### Table Name: ProcessOwnersTable

| Column Name | Type | Description |
|------------|------|-------------|
| SiteName | Text | SharePoint site name |
| SiteURL | Text | Full SharePoint site URL |
| ProcessName | Text | Extracted process name (e.g., "SITS", "Problem") |
| FieldType | Text | "Owner" or "Manager" |
| PersonName | Text | Display name from people picker |
| PersonEmail | Text | Email address |
| LastUpdated | DateTime | Timestamp of last verification/update |
| Status | Text | "Active", "Changed", "New" |

---

## Implementation Steps

### 1. Create Excel Template
1. Create new Excel file in SharePoint/OneDrive
2. Name it: `Process_Owners_Tracker.xlsx`
3. Create table with columns listed above
4. Format as Table (Insert > Table)
5. Name table: `ProcessOwnersTable`

### 2. Build the Flow

#### Create New Flow
1. Go to Power Automate (https://make.powerautomate.com)
2. Create > Scheduled cloud flow
3. Name: "SharePoint Process Owners Extractor"
4. Recurrence: Daily at 2:00 AM

#### Add SharePoint Sites Array
```json
[
  "https://yourcompany.sharepoint.com/sites/Finance",
  "https://yourcompany.sharepoint.com/sites/IT",
  "https://yourcompany.sharepoint.com/sites/HR",
  "https://yourcompany.sharepoint.com/sites/Operations"
]
```

#### Key Actions to Add
1. **Recurrence** trigger (Daily, 2:00 AM)
2. **Initialize variable** - SharePointSites (Array)
3. **Initialize variable** - ExcelPath (String)
4. **Apply to each** - SharePointSites
5. Inside loop:
   - **Get items** (SharePoint) - from relevant lists
   - **Apply to each** - items
   - **Compose** - extract person fields
   - **Condition** - check if field matches pattern
   - **List rows** - from Excel
   - **Condition** - check if row exists
   - **Add/Update row** - in Excel table
6. **Send email** - summary report

### 3. Field Name Pattern Matching

Use expressions to match field names dynamically:

```
contains(item()?['FieldInternalName'], 'ProcessOwner')
or(
  contains(item()?['FieldInternalName'], 'ProcessManager'),
  contains(item()?['FieldInternalName'], 'Process Owner'),
  contains(item()?['FieldInternalName'], 'Process Manager')
)
```

### 4. Extract Process Name from Field

Use expression to extract prefix:

```
if(
  contains(item()?['FieldName'], 'Process Owner'),
  split(item()?['FieldName'], 'Process Owner')[0],
  split(item()?['FieldName'], 'Process Manager')[0]
)
```

---

## Advanced Features (Optional)

### 1. Change Tracking
Add columns to track changes:
- PreviousOwner
- ChangeDate
- ChangeHistory (JSON)

### 2. Notifications on Changes
Send email when specific processes change owners:
```
Condition: If PersonName != PreviousOwner
Action: Send email to stakeholders
```

### 3. Multiple People in Field
Handle cases where Process Owner field contains multiple people:
```
Apply to each: PersonField?['value']
  Add row for each person
```

### 4. Archive Old Data
Before updating, copy current data to archive sheet:
```
Monthly: Copy ProcessOwnersTable to ProcessOwnersArchive_[Month]
```

---

## Testing Plan

### Phase 1: Single Site Testing
1. Test with one SharePoint site
2. Verify field detection
3. Confirm Excel write operations
4. Check error handling

### Phase 2: Multi-Site Testing
1. Add 2-3 sites
2. Test concurrent processing
3. Verify data consistency
4. Monitor performance

### Phase 3: Production Deployment
1. Add all target sites
2. Schedule for off-hours
3. Monitor first week daily
4. Set up alerting for failures

---

## Troubleshooting

### Common Issues

#### Issue 1: People Picker Field Not Reading
**Solution**: Ensure field is expanded in SharePoint query
```
$expand=ProcessOwner,ProcessManager
```

#### Issue 2: Field Names Vary by Site
**Solution**: Use dynamic field name detection with Get list (SharePoint) action to read column schema

#### Issue 3: Excel File Locked
**Solution**: Add retry logic with 5-minute delay

#### Issue 4: Permissions
**Solution**: Ensure flow has:
- Read access to all SharePoint sites
- Write access to Excel file location
- SharePoint Admin approval for HTTP requests

---

## Permissions Required

### SharePoint
- **Site Collection**: Read permissions on all target sites
- **Lists/Libraries**: Read item permissions
- **User Profiles**: Access to read user information

### Excel File Location
- **Edit permissions** on folder/library where Excel file is stored

### Power Automate
- **SharePoint connector**: Requires authentication
- **Excel Online (Business) connector**: Requires authentication
- **Office 365 Outlook**: For email notifications

---

## Maintenance

### Weekly
- Check flow run history for errors
- Review Excel file for data quality

### Monthly
- Update SharePoint sites list if new sites added
- Archive old data if needed
- Review and optimize performance

### Quarterly
- Review field name patterns (in case of naming changes)
- Update stakeholder distribution lists

---

## Cost Considerations

### Power Automate License
- **Power Automate per user plan**: Included with Office 365 E3/E5
- **Pay-as-you-go**: Charged per flow run
- **Premium connectors**: HTTP connector may require premium license

### API Calls
- Each SharePoint site = 1-5 API calls
- Each item retrieved = 1 API call
- Excel operations = 1 API call per row operation
- Consider API throttling limits

---

## Alternative Approaches

### Option 1: Power Apps + SharePoint List
Instead of Excel, store data in SharePoint list for better scalability

### Option 2: Microsoft Graph API
Use Graph API for more efficient bulk data retrieval

### Option 3: Azure Logic Apps
For enterprise-scale with better performance and monitoring

---

## Next Steps

1. ✅ Create Excel template file
2. ✅ Gather list of all SharePoint site URLs
3. ✅ Identify exact field names in each site
4. ✅ Create Power Automate flow with basic structure
5. ✅ Test with single site
6. ✅ Add error handling and logging
7. ✅ Deploy to all sites
8. ✅ Schedule and monitor

---

## Contact & Support

For issues with this flow:
1. Check Power Automate flow run history
2. Review error logs in Excel/SharePoint
3. Contact SharePoint administrator for permission issues
4. Review Power Automate documentation: https://docs.microsoft.com/power-automate/

---

*Document Version: 1.0*
*Last Updated: 2026-01-09*
*Created for: SharePoint Process Owners Tracking Project*
