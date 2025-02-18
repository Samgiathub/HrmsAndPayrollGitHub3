using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100KpiratingLevel
{
    public decimal RowId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? TranId { get; set; }

    public decimal? SubKpiid { get; set; }

    public string? MetricManager { get; set; }

    public decimal? RatingManager { get; set; }

    public decimal? AchievedWeightManager { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0030HrmsRatingMaster? RatingManagerNavigation { get; set; }

    public virtual T0080SubKpiMaster? SubKpi { get; set; }

    public virtual T0090KpipmsEvalApproval? Tran { get; set; }
}
