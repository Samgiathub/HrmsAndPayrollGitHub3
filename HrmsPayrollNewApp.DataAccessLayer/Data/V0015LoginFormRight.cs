using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0015LoginFormRight
{
    public decimal FormId { get; set; }

    public string FormName { get; set; } = null!;

    public decimal UnderFormId { get; set; }

    public decimal SortId { get; set; }

    public byte FormType { get; set; }

    public string? FormUrl { get; set; }

    public string? FormImageUrl { get; set; }

    public byte IsActiveForMenu { get; set; }

    public string? Alias { get; set; }

    public decimal SortIdCheck { get; set; }

    public string? ModuleName { get; set; }

    public string? PageFlag { get; set; }

    public string? ChineseAlias { get; set; }

    public decimal LoginId { get; set; }

    public string LoginName { get; set; } = null!;

    public string LoginPassword { get; set; } = null!;
}
