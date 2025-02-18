using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120TrainingApproval
{
    public decimal TrainingAprId { get; set; }

    public decimal? TrainingAppId { get; set; }

    public decimal LoginId { get; set; }

    public DateTime TrainingDate { get; set; }

    public string Place { get; set; } = null!;

    public string Faculty { get; set; } = null!;

    public string CompanyName { get; set; } = null!;

    public string? Description { get; set; }

    public decimal? TrainingCost { get; set; }

    public string AprStatus { get; set; } = null!;

    public decimal CmpId { get; set; }

    public DateTime? TrainingEndDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0100TrainingApplication? TrainingApp { get; set; }
}
