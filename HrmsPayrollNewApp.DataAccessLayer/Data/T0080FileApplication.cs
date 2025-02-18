using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080FileApplication
{
    public decimal FileAppId { get; set; }

    public DateTime? ApplicationDate { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public string FileNumber { get; set; } = null!;

    public int? FStatusId { get; set; }

    public decimal? FTypeId { get; set; }

    public string? Subject { get; set; }

    public string? Description { get; set; }

    public DateTime? ProcessDate { get; set; }

    public string? FileAppDoc { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? CreatedDate { get; set; }

    public DateTime? UpdatedDate { get; set; }

    public string? UpdatedByUserId { get; set; }

    public string? UserId { get; set; }

    public string? Rcomments { get; set; }

    public decimal? ReviewEmpId { get; set; }

    public string? FileTypeNumber { get; set; }

    public string? FileTypeName { get; set; }

    public virtual ICollection<T0115FileLevelApproval> T0115FileLevelApprovals { get; set; } = new List<T0115FileLevelApproval>();
}
