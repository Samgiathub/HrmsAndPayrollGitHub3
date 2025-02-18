using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140BondTransaction
{
    public decimal BondTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BondId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal BondOpening { get; set; }

    public decimal BondIssue { get; set; }

    public decimal BondReturn { get; set; }

    public decimal BondClosing { get; set; }

    public virtual T0040BondMaster Bond { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
