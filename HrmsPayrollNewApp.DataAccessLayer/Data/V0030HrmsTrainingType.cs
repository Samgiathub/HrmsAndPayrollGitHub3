using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0030HrmsTrainingType
{
    public decimal TrainingTypeId { get; set; }

    public decimal CmpId { get; set; }

    public string TrainingTypeName { get; set; } = null!;

    public byte TypeOjt { get; set; }

    public byte TypeInduction { get; set; }

    public string InductionTraningDept { get; set; } = null!;
}
