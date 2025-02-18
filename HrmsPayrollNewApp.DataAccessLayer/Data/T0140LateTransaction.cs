using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140LateTransaction
{
    public decimal LTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal LateOpening { get; set; }

    public decimal LateCredit { get; set; }

    public decimal LateDebit { get; set; }

    public decimal LateClosing { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
