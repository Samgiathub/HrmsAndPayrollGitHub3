using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0115TravelApprovalAdvdetailLevelBackupYogesh28122022
{
    public decimal TranId { get; set; }

    public decimal TravelAdvanceDetailId { get; set; }

    public decimal CmpId { get; set; }

    public string ExpenceType { get; set; } = null!;

    public decimal Amount { get; set; }

    public string? AdvDetailDesc { get; set; }

    public long? SrNo { get; set; }

    public decimal? CurrId { get; set; }

    public string? Currency { get; set; }
}
