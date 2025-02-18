using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050TrainingWiseCheckList
{
    public decimal TrainingId { get; set; }

    public string? TrainingName { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? CmpId { get; set; }

    public decimal TranId { get; set; }

    public string? AssignChecklist { get; set; }
}
