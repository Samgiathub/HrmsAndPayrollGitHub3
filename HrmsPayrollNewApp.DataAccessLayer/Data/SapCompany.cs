using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SapCompany
{
    public int CmpId { get; set; }

    public string? CompanyCode { get; set; }

    public string? CompanyName { get; set; }
}
