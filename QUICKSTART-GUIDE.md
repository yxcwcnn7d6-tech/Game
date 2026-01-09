# Quick Start Guide: Building Your SharePoint Process Owners Flow

## Prerequisites Checklist
- [ ] Office 365 account with Power Automate access
- [ ] Read permissions on all target SharePoint sites
- [ ] OneDrive or SharePoint location for Excel file
- [ ] List of SharePoint site URLs
- [ ] Sample of actual field names from your sites

---

## Part 1: Prepare Excel File (15 minutes)

### Step 1: Create Excel File
1. Open Excel Online (OneDrive or SharePoint)
2. Create new blank workbook
3. Name it: `Process_Owners_Tracker.xlsx`

### Step 2: Set Up Table
1. In cell A1, add these headers:
   ```
   SiteName | SiteURL | ProcessName | FieldType | PersonName | PersonEmail | LastUpdated | Status
   ```

2. Select the header row (A1:H1)
3. Click **Insert** > **Table** > Check "My table has headers" > OK
4. Click on table, go to **Table Design** > Name: `ProcessOwnersTable`
5. Save the file

### Step 3: Note File Location
Copy the full path to this file - you'll need it later.
Example: `/Shared Documents/Process_Owners_Tracker.xlsx`

---

## Part 2: Identify Your SharePoint Fields (10 minutes)

### Step 1: Visit Each SharePoint Site
Go to one of your SharePoint sites that has process information.

### Step 2: Find Process Owner Fields
1. Open a document library or list that contains process information
2. Click on any item and view its properties/details
3. Look for fields containing:
   - "Process Owner"
   - "Process Owners"
   - "Process Manager"
   - "Process Managers"
   - Or variations like "SITS Process Owners"

### Step 3: Document Field Names
Create a list like this:
```
Site: Finance SharePoint
- Field: "Process Owner" (people picker)
- Field: "Process Manager" (people picker)
- Field: "SITS Process Owners" (people picker)

Site: IT SharePoint
- Field: "Problem Process Owners" (people picker)
- Field: "Service Process Managers" (people picker)
```

### Step 4: Note Internal Field Names (Optional but Recommended)
1. Go to List Settings > Click on the field name
2. Look at URL - it shows `Field=ProcessOwner` or similar
3. Note this internal name - it's more reliable than display names

---

## Part 3: Build the Flow (30-45 minutes)

### Step 1: Create New Flow
1. Go to https://make.powerautomate.com
2. Click **Create** > **Scheduled cloud flow**
3. Name: `SharePoint Process Owners Extractor`
4. Run: **Daily** at **2:00 AM**
5. Click **Create**

---

### Step 2: Initialize Variables

Add these actions (click **+ New step** after each):

#### Variable 1: SharePoint Sites
- **Action**: Initialize variable
- **Name**: `SharePointSites`
- **Type**: Array
- **Value**:
  ```json
  [
    "https://yourcompany.sharepoint.com/sites/Finance",
    "https://yourcompany.sharepoint.com/sites/IT"
  ]
  ```
  *(Replace with your actual site URLs)*

#### Variable 2: Excel Details
- **Action**: Initialize variable (add 3 times for each)

  **Variable A:**
  - Name: `ExcelSiteAddress`
  - Type: String
  - Value: `https://yourcompany.sharepoint.com/sites/YourSite`

  **Variable B:**
  - Name: `ExcelFilePath`
  - Type: String
  - Value: `/Shared Documents/Process_Owners_Tracker.xlsx`

  **Variable C:**
  - Name: `ExcelTableName`
  - Type: String
  - Value: `ProcessOwnersTable`

#### Variable 3: Data Collection
- **Action**: Initialize variable
- **Name**: `ExtractedData`
- **Type**: Array
- **Value**: Leave empty `[]`

---

### Step 3: Loop Through Sites

#### Add Apply to Each Loop
- **Action**: Apply to each
- **Select output from previous steps**: `SharePointSites` (from dynamic content)

Inside this loop, add the following:

#### 3.1: Set Current Site Variable
- **Action**: Set variable
- **Name**: `CurrentSite`
- **Value**: `Current item` (from dynamic content)

#### 3.2: Get Lists from Site
- **Action**: Send an HTTP request to SharePoint
- **Site Address**: `Current item`
- **Method**: GET
- **Uri**: `_api/web/lists?$filter=Hidden eq false`
- **Headers**:
  ```json
  {
    "Accept": "application/json;odata=nometadata"
  }
  ```

#### 3.3: Parse Lists Response
- **Action**: Parse JSON
- **Content**: `Body` (from previous step)
- **Schema**: Click "Use sample payload" and paste:
  ```json
  {
    "value": [
      {
        "Id": "guid",
        "Title": "Documents",
        "BaseType": 1
      }
    ]
  }
  ```

#### 3.4: Loop Through Lists (nested loop)
- **Action**: Apply to each
- **Select**: `value` (from Parse JSON)

Inside this nested loop:

##### 3.4.1: Get Items from List
- **Action**: Get items
- **Site Address**: `CurrentSite`
- **List Name**: `Id` (from current list item)
- **Limit**: 5000

##### 3.4.2: Loop Through Items (third nested loop)
- **Action**: Apply to each
- **Select**: `value` (from Get items)

Inside this third loop, you'll extract the person fields.

---

### Step 4: Extract Person Fields (This is the key part!)

Since field names vary, you need to handle this dynamically.

#### Approach A: If Field Names are Consistent

If your sites use the same field names (e.g., always "ProcessOwner"):

1. **Action**: Condition
   - **Left side**: `ProcessOwner DisplayName` (from dynamic content)
   - **Condition**: is not equal to
   - **Right side**: (leave empty to check if field exists)

2. **If Yes**: Add these actions:

   **Action**: Compose
   - **Inputs**:
   ```json
   {
     "SiteName": "@{items('Apply_to_each')?['Title']}",
     "SiteURL": "@{variables('CurrentSite')}",
     "ProcessName": "",
     "FieldType": "Owner",
     "PersonName": "@{items('Apply_to_each_3')?['ProcessOwner']?['DisplayName']}",
     "PersonEmail": "@{items('Apply_to_each_3')?['ProcessOwner']?['Email']}",
     "LastUpdated": "@{utcNow()}",
     "Status": "Active"
   }
   ```

   **Action**: Append to array variable
   - **Name**: `ExtractedData`
   - **Value**: `Outputs` (from Compose)

3. Repeat for each field type (ProcessOwner, ProcessManager, etc.)

#### Approach B: If Field Names Vary (Recommended)

Use expressions to check multiple field patterns:

1. **Action**: Condition
   - **Left side**: Click formula (fx) and enter:
     ```
     or(
       not(empty(item()?['ProcessOwner'])),
       not(empty(item()?['ProcessManager'])),
       not(empty(item()?['SITSProcessOwners'])),
       not(empty(item()?['ProblemProcessOwners']))
     )
     ```

2. Follow similar Compose + Append pattern as above

---

### Step 5: Update Excel File

After all loops complete, add these actions:

#### 5.1: List Rows from Excel
- **Action**: List rows present in a table
- **Location**: OneDrive or SharePoint
- **Document Library**: Documents
- **File**: Select your Excel file
- **Table**: `ProcessOwnersTable`

#### 5.2: Loop Through Extracted Data
- **Action**: Apply to each
- **Select**: `ExtractedData` variable

Inside loop:

##### Check if Row Exists
- **Action**: Condition
- **Left side**: Formula:
  ```
  contains(string(body('List_rows_present_in_a_table')), items('Apply_to_each_final')?['PersonEmail'])
  ```
- **Condition**: is equal to
- **Right side**: `true`

**If No (New Record)**:
- **Action**: Add a row into a table
- **Location**: OneDrive/SharePoint
- **Document Library**: Documents
- **File**: Your Excel file
- **Table**: `ProcessOwnersTable`
- **Map each column**: Use dynamic content from current item

**If Yes (Existing Record)** - Optional:
- Add logic to update the row if needed
- Use **Update a row** action

---

### Step 6: Send Summary Email (Optional)

After the final loop:

1. **Action**: Compose
   - **Inputs**:
     ```
     Sites Processed: @{length(variables('SharePointSites'))}
     Records Found: @{length(variables('ExtractedData'))}
     Completed At: @{utcNow()}
     ```

2. **Action**: Send an email (V2)
   - **To**: Your email
   - **Subject**: `SharePoint Process Owners Update - @{formatDateTime(utcNow(), 'yyyy-MM-dd')}`
   - **Body**: Use the Compose output

---

### Step 7: Add Error Handling

1. Select the "Apply to each" (sites loop)
2. Click **...** (three dots) > **Configure run after**
3. Add parallel branch
4. **Action**: Send an email (V2)
   - **To**: Your email
   - **Subject**: "ERROR: SharePoint Process Owners Flow Failed"
   - **Body**: "Please check flow run history"
5. Click on this action > **...** > **Configure run after** > Check only "has failed"

---

## Part 4: Test the Flow (10 minutes)

### Test Run 1: Manual Trigger
1. Click **Save** (top right)
2. Click **Test** > **Manually** > **Test**
3. Wait for completion (may take 2-10 minutes depending on data size)

### Check Results
1. Go to your Excel file
2. Verify data is populated
3. Check for any errors in flow run history

### Debug Common Issues
- **"File not found"**: Check Excel file path
- **"Forbidden"**: Check permissions on SharePoint sites
- **"Column not found"**: Verify table name and column names match exactly
- **"Null reference"**: Some items might not have the person field filled in - add null checks

---

## Part 5: Optimize & Deploy (15 minutes)

### Add Filtering
To improve performance, modify **Get items** actions:

1. Click on each "Get items" action
2. Click **Show advanced options**
3. **Filter Query**:
   ```
   ProcessOwner ne null or ProcessManager ne null
   ```
   *(Adjust field names to match yours)*

### Add More Sites
1. Edit the flow
2. Update `SharePointSites` variable array
3. Add more URLs

### Schedule for Production
1. The flow is already scheduled (daily at 2 AM)
2. Monitor for first week
3. Adjust timing if needed (edit Recurrence trigger)

---

## Simplified Version (If Above is Too Complex)

### Alternative: Manual Site Specification

Instead of looping through all lists dynamically, manually add Get Items for specific lists:

**For each site/list combination:**

1. **Action**: Get items
   - **Site Address**: `https://yourcompany.sharepoint.com/sites/Finance`
   - **List Name**: `Process Documentation`

2. **Action**: Apply to each
   - **Select**: `value` from Get items

3. **Action**: Condition
   - Check if ProcessOwner exists

4. **Action**: Add row to Excel table

Repeat this pattern for each site/list combination you want to monitor.

**Pros**: Simpler, more predictable
**Cons**: More manual maintenance when adding new sites

---

## Monitoring & Maintenance

### Weekly Check
1. Go to Power Automate
2. Click **My flows**
3. Find your flow
4. Check **Run history** - ensure all runs succeeded

### Monthly Review
1. Open Excel file
2. Check data quality
3. Remove any duplicates or stale records
4. Update site list if needed

---

## Troubleshooting Guide

### Flow Fails with "Unauthorized"
**Solution**:
1. Edit flow
2. Re-authenticate SharePoint connections
3. Ensure you have read access to all sites

### Flow Runs but No Data in Excel
**Solution**:
1. Check if person fields actually contain data in SharePoint
2. Verify field names match exactly (case-sensitive)
3. Add **Compose** actions to debug - output the item data to see structure

### Flow Times Out
**Solution**:
1. Reduce number of sites processed per run
2. Add pagination for large lists
3. Consider splitting into multiple flows by department

### Duplicate Records
**Solution**:
1. Improve the "check if exists" logic
2. Use unique identifier combining Site + Process + Email
3. Add deduplication step at end

### People Picker Field Returns Null
**Solution**:
1. Use **Get item** instead of **Get items** with expand:
   ```
   $expand=ProcessOwner,ProcessManager
   ```

---

## Need Help?

### Resources
- Power Automate Documentation: https://docs.microsoft.com/power-automate/
- SharePoint REST API: https://docs.microsoft.com/sharepoint/dev/sp-add-ins/get-to-know-the-sharepoint-rest-service
- Excel Online Connector: https://docs.microsoft.com/connectors/excelonlinebusiness/

### Common Search Terms for Help
- "Power Automate loop through SharePoint sites"
- "Extract people picker field Power Automate"
- "Update Excel from SharePoint Power Automate"
- "Dynamic field names Power Automate"

---

## Success Criteria

Your flow is working correctly when:
- ✅ Runs successfully every night (check for 1 week straight)
- ✅ Excel file updates with new data
- ✅ All sites are processed without errors
- ✅ Person names and emails are accurate
- ✅ Duplicate records are not created
- ✅ Changes in SharePoint are reflected in Excel within 24 hours

---

## Next Steps After Basic Flow Works

1. **Add Change Detection**: Track when owners change and send alerts
2. **Create Dashboard**: Use Excel data in Power BI for visualization
3. **Add Approval Workflow**: Route to managers when owners change
4. **Integrate with Teams**: Post updates to Teams channel
5. **Create Process Catalog**: Build SharePoint list with process metadata
6. **Add Governance**: Implement owner certification workflow

---

*Good luck building your flow! Start simple, test often, and expand gradually.*
