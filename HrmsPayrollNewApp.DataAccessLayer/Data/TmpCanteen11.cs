using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TmpCanteen11
{
    public decimal EmpId { get; set; }

    public int? TotalEveningSnackCount { get; set; }

    public decimal? GrdId { get; set; }

    public int? ExtraEveningSnack { get; set; }

    public decimal? TotalExtraEveningSnackAmount { get; set; }

    public decimal? GstPercentEveningSnack { get; set; }

    public decimal? GstEveningSnackAmount { get; set; }

    public decimal? NetEveningSnackAmount { get; set; }
}
