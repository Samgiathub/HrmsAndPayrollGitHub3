using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140AssetTransaction
{
    public decimal AssetTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? AssetApprovalId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? AssetMId { get; set; }

    public decimal AssetOpening { get; set; }

    public decimal IssueAmount { get; set; }

    public decimal ReceiveAmount { get; set; }

    public decimal AssetClosing { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? SalTranId { get; set; }

    public virtual T0120AssetApproval? AssetApproval { get; set; }

    public virtual T0040AssetDetail? AssetM { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? Emp { get; set; }
}
