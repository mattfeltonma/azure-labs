@{
    AllNodes = @()
    NonNodeData = @{
        OrganizationalUnits = 'Admins','Employees','Desktops','Servers','Groups'
        AdUsers = @(
            @{
                FirstName = 'Homer'
                LastName = 'Simpson'
                Department = 'Finance'
                Title = 'Director of Finance'
                Office = 'Boston'
                OfficePhone = '555-5550'
                EmployeeID = '000001'
                UserName = 'homer.simpson'
                Description = 'Finance - Director of Finance'
                EmailAddress = 'homer.simpson@journeyofthegeek.com'
            }
            @{
                FirstName = 'Marge'
                LastName = 'Simpson'
                Department = 'Finance'
                Title = 'CFO'
                Office = 'Boston'
                OfficePhone = '555-5551'
                EmployeeID = '000002'
                UserName = 'marge.simpson'
                Description = 'Finance - Chief Financial Officer'
                EmailAddress = 'marge.simpson@journeyofthegeek.com'
            }
            @{
                FirstName = 'Edna'
                LastName = 'Krabappel'
                Department = 'Finance'
                Title = 'Financial Analyst'
                Office = 'Boston'
                OfficePhone = '555-5552'
                EmployeeID = '000003'
                UserName = 'edna.krabappel'
                Description = 'Finance - Financial Analyst'
                EmailAddress = 'edna.krabappel@journeyofthegeek.com'
            }
            @{
                FirstName = 'Lisa'
                LastName = 'Simpson'
                Department = 'Human Resource'
                Title = 'Director of HR'
                Office = 'Boston'
                OfficePhone = '555-5553'
                EmployeeID = '000004'
                UserName = 'lisa.simpson'
                Description = 'Human Resource - Director of HR'
                EmailAddress = 'lisa.simpson@journeyofthegeek.com'
            }
            @{
                FirstName = 'Bart'
                LastName = 'Simpson'
                Department = 'Central IT'
                Title = 'CIO'
                Office = 'Boston'
                OfficePhone = '555-5554'
                EmployeeID = '000005'
                UserName = 'bart.simpson'
                Description = 'Central IT - Chief Information Officer'
                EmailAddress = 'bart.simpson@journeyofthegeek.com'
            }
            @{
                FirstName = 'Ned'
                LastName = 'Flanders'
                Department = 'Central IT'
                Title = 'Network Engineer'
                Office = 'New York'
                OfficePhone = '555-5555'
                EmployeeID = '000006'
                UserName = 'ned.flanders'
                Description = 'Central IT - Network Engineer'
                EmailAddress = 'ned.flanders@journeyofthegeek.com'
            }
            @{
                FirstName = 'Milhouse'
                LastName = 'Van Houten'
                Department = 'Central IT'
                Title = 'Systems Engineer'
                Office = 'New York'
                OfficePhone = '555-5556'
                EmployeeID = '000007'
                UserName = 'milhouse.vanhouten'
                Description = 'Central IT - Systems Engineer'
                EmailAddress = 'milhouse.vanhouten@journeyofthegeek.com'
            }
            @{
                FirstName = 'Moe'
                LastName = 'Szyslak'
                Department = 'Central IT'
                Title = 'Help Desk Engineer'
                Office = 'Boston'
                OfficePhone = '555-5557'
                EmployeeID = '000008'
                UserName = 'moe.szyslak'
                Description = 'Central IT - Help Desk Engineer'
                EmailAddress = 'moe.szyslak@journeyofthegeek.com'
            }
            @{
                FirstName = 'Maggie'
                LastName = 'Simpson'
                Department = 'Information Security'
                Title = 'CISO'
                Office = 'Boston'
                OfficePhone = '555-5558'
                EmployeeID = '000009'
                UserName = 'maggie.simpson'
                Description = 'Information Security - Chief Information Security Officer'
                EmailAddress = 'maggie.simpson@journeyofthegeek.com'
            }
            @{
                FirstName = 'Barnie'
                LastName = 'Gumble'
                Department = 'Information Security'
                Title = 'Security Engineer'
                Office = 'New York'
                OfficePhone = '555-5559'
                EmployeeID = '000010'
                UserName = 'barnie.gumble'
                Description = 'Information Security - Security Engineer'
                EmailAddress = 'barnie.gumble@journeyofthegeek.com'
            }
        )
        AdGroups = @(
            @{
                GroupName = 'Finance'
                GroupScope = 'Universal'
                GroupCategory = 'Security'
                Description = 'Finance Department'
                Members = @(
                    'homer.simpson'
                    'marge.simpson'
                    'edna.krabappel'
                )
            }
            @{
                GroupName = 'Central IT'
                GroupScope = 'Universal'
                GroupCategory = 'Security'
                Description = 'Central IT Department'
                Members = @(
                    'bart.simpson'
                    'ned.flanders'
                    'milhouse.vanhouten'
                    'moe.szyslak'
                )
            }
            @{
                GroupName = 'Information Security'
                GroupScope = 'Universal'
                GroupCategory = 'Security'
                Description = 'Information Security Department'
                Members = @(
                    'maggie.simpson'
                    'barnie.gumble'
                )
            }
            @{
                GroupName = 'Executives'
                GroupScope = 'Universal'
                GroupCategory = 'Security'
                Description = 'Executives'
                Members = @(
                    'marge.simpson'
                    'bart.simpson'
                    'maggie.simpson'
                )
            }
        )  
    }
}