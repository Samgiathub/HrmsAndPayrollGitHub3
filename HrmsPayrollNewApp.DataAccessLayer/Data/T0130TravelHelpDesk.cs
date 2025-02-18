using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0130TravelHelpDesk
{
    public decimal TranId { get; set; }

    public decimal TravelApprovalId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string? FileName { get; set; }

    public string? Remarks { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0120TravelApproval TravelApproval { get; set; } = null!;
}
