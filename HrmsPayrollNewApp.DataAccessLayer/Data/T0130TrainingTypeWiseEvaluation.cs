using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0130TrainingTypeWiseEvaluation
{
    public decimal TrainingEvaluationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string FinancialYear { get; set; } = null!;

    public decimal TrainingTypeId { get; set; }

    public decimal TrainingId { get; set; }

    public decimal Desired { get; set; }

    public decimal Present { get; set; }
}
