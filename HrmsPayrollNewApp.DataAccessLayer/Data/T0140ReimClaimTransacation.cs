using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140ReimClaimTransacation
{
    public decimal ReimTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal RcId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal ReimOpening { get; set; }

    public decimal ReimCredit { get; set; }

    public decimal ReimDebit { get; set; }

    public decimal ReimClosing { get; set; }

    public decimal? RcAprId { get; set; }

    public decimal? SalTranId { get; set; }

    public decimal? SSalTranId { get; set; }

    public decimal ReimSettCrAmount { get; set; }

    public DateTime SysDate { get; set; }

    public byte ForFnf { get; set; }

    public decimal PostingAmount { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0050AdMaster Rc { get; set; } = null!;
}
