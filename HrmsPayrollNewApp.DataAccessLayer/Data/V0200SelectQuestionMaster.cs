using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0200SelectQuestionMaster
{
    public decimal QuestionId { get; set; }

    public string Question { get; set; } = null!;

    public string? Description { get; set; }

    public decimal CmpId { get; set; }

    public byte IsActive { get; set; }

    public string StatusColor { get; set; } = null!;
}
