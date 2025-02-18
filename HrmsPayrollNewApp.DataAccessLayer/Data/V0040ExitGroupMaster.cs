using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040ExitGroupMaster
{
    public decimal GroupId { get; set; }

    public string GroupName { get; set; } = null!;

    public decimal CmpId { get; set; }

    public bool IsActive { get; set; }

    public byte QActive { get; set; }

    public decimal EmpId { get; set; }
}
