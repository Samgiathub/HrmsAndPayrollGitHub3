using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040TemplateMaster
{
    public int TId { get; set; }

    public int CmpId { get; set; }

    public string? TemplateTitle { get; set; }

    public string? TemplateInstruction { get; set; }

    public decimal? BranchId { get; set; }

    public string? EmpId { get; set; }

    public int? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public int? UpdateBy { get; set; }

    public DateTime? UpdateDate { get; set; }

    public int? IsActive { get; set; }

    public string? DesigId { get; set; }
}
