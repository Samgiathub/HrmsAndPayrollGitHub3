using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140AdvanceTransaction
{
    public decimal AdvTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal AdvOpening { get; set; }

    public decimal AdvIssue { get; set; }

    public decimal AdvReturn { get; set; }

    public decimal AdvClosing { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
