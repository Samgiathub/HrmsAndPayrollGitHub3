using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0052HrmsAttributeFeedback
{
    public decimal EmpAttId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? InitiationId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? PaId { get; set; }

    public string? AttType { get; set; }

    public decimal? AttScore { get; set; }

    public decimal? AttAchievement { get; set; }

    public string? AttCritical { get; set; }

    public decimal? ThresholdValue { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0050HrmsInitiateAppraisal? Initiation { get; set; }

    public virtual T0040HrmsAttributeMaster? Pa { get; set; }
}
