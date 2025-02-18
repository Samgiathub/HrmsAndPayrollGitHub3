using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050ProjectMasterPayroll
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public string ProjectName { get; set; } = null!;

    public decimal ProjectManagerId { get; set; }

    public string? CustomerName { get; set; }

    public string? SiteId { get; set; }

    public string? Remarks { get; set; }

    public DateTime ModifyDate { get; set; }

    public string? ProjectManager { get; set; }
}
