using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110HrmsAppraisalPlanDetail
{
    public decimal HpdId { get; set; }

    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal InitiateId { get; set; }

    public string? Plan { get; set; }

    public string? Area { get; set; }

    public decimal? MethodId { get; set; }

    public decimal? TimeFrameId { get; set; }

    public string? Comments { get; set; }

    public string? ApprovalLevel { get; set; }

    public virtual T0050HrmsInitiateAppraisal Initiate { get; set; } = null!;

    public virtual T0040HrmsMethodMaster? Method { get; set; }

    public virtual T0040HrmsTimeFrameMaster? TimeFrame { get; set; }
}
