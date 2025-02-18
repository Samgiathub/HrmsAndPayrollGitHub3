using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040PolicyDocMaster
{
    public decimal PolicyDocId { get; set; }

    public decimal CmpId { get; set; }

    public string PolicyTitle { get; set; } = null!;

    public string PolicyTooltip { get; set; } = null!;

    public string PolicyUploadDoc { get; set; } = null!;

    public DateTime PolicyFromDate { get; set; }

    public DateTime PolicyToDate { get; set; }

    public decimal PolicySorting { get; set; }

    public string? EmpId { get; set; }

    public string? DeptId { get; set; }

    public string? CmpIdMulti { get; set; }

    public int? PolicyType { get; set; }

    public byte DocType { get; set; }
}
