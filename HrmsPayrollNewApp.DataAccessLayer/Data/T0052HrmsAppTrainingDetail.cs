using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0052HrmsAppTrainingDetail
{
    public decimal AppTrainingdetailId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? InitiateId { get; set; }

    public decimal? EmpId { get; set; }

    public string? Type { get; set; }

    public string? TrainingAreas { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0050HrmsInitiateAppraisal? Initiate { get; set; }
}
