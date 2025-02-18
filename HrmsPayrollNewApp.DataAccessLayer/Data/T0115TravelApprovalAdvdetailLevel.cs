using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115TravelApprovalAdvdetailLevel
{
    public decimal RowAdvId { get; set; }

    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public string ExpenceType { get; set; } = null!;

    public decimal Amount { get; set; }

    public string? AdvDetailDesc { get; set; }

    public decimal TravelAppId { get; set; }

    public decimal? CurrId { get; set; }

    public decimal? AmountDollar { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0115TravelLevelApproval Tran { get; set; } = null!;
}
