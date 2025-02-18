using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0511OfficerDetail
{
    public int Srno { get; set; }

    public decimal? CmpId { get; set; }

    public string? OfficerName { get; set; }

    public decimal? OfficerBranch { get; set; }

    public string? OfficerDepartment { get; set; }

    public string? Emailid { get; set; }

    public decimal? Contact { get; set; }

    public string? Address { get; set; }
}
