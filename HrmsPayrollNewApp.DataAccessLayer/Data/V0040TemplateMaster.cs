using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040TemplateMaster
{
    public int TId { get; set; }

    public int CmpId { get; set; }

    public string? TemplateTitle { get; set; }

    public string? TemplateInstruction { get; set; }

    public int? CreatedBy { get; set; }

    public decimal? BranchId { get; set; }

    public string? DesigId { get; set; }

    public string? BranchName { get; set; }

    public string? DesigName { get; set; }

    public string? EmpId { get; set; }

    public string? Employee { get; set; }

    public byte? IsActive { get; set; }
}
