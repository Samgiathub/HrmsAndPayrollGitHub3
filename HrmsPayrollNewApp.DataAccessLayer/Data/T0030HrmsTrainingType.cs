using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0030HrmsTrainingType
{
    public decimal TrainingTypeId { get; set; }

    public decimal CmpId { get; set; }

    public string TrainingTypeName { get; set; } = null!;

    public byte? TypeOjt { get; set; }

    public byte? TypeInduction { get; set; }

    public byte InductionTraningDept { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
