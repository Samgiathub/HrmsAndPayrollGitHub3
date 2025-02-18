using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040ExitGroupMaster
{
    public decimal GroupId { get; set; }

    public decimal CmpId { get; set; }

    public string GroupName { get; set; } = null!;

    public decimal GroupSortId { get; set; }

    public bool IsActive { get; set; }

    public string GrpRateId { get; set; } = null!;

    public DateTime SystemDate { get; set; }
}
