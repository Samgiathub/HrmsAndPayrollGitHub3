using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0020PrivilegeMasterDetailsBackupMehul20072022
{
    public decimal PrivilegeId { get; set; }

    public decimal CmpId { get; set; }

    public string? PrivilegeName { get; set; }

    public decimal FormId { get; set; }

    public byte IsView { get; set; }

    public byte IsEdit { get; set; }

    public byte IsSave { get; set; }

    public byte IsDelete { get; set; }

    public string FormName { get; set; } = null!;

    public decimal UnderFormId { get; set; }

    public decimal SortId { get; set; }

    public byte FormType { get; set; }

    public string? FormUrl { get; set; }

    public string? FormImageUrl { get; set; }

    public int IsActive { get; set; }

    public byte IsActiveForMenu { get; set; }

    public string? Alias { get; set; }

    public decimal SortIdCheck { get; set; }

    public string? ModuleName { get; set; }

    public string? PageFlag { get; set; }

    public string? ChineseAlias { get; set; }
}
