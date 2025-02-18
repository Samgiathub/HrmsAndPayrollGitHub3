using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0000DefaultForm
{
    public decimal FormId { get; set; }

    public string FormName { get; set; } = null!;

    public string? FormImageUrl { get; set; }

    public byte FormType { get; set; }

    public string? FormUrl { get; set; }

    public byte IsActiveForMenu { get; set; }

    public decimal SortId { get; set; }

    public decimal UnderFormId { get; set; }

    public string? UnderFormName { get; set; }

    public string FormStatus { get; set; } = null!;

    public string? Alias { get; set; }
}
