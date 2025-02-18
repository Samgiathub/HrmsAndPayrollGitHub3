using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100ItDeclarationRecord
{
    public string? ItName { get; set; }

    public string? FinancialYear { get; set; }

    public decimal ProvisionalAmount { get; set; }

    public decimal ApprovalAmount { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public string? EmpFullName { get; set; }

    public string Status { get; set; } = null!;

    public decimal ItId { get; set; }

    public string? Monthyear { get; set; }

    public DateTime ForDate { get; set; }

    public string DocName { get; set; } = null!;

    public decimal? LoginId { get; set; }

    public bool IsLock { get; set; }

    public byte IsMetroCity { get; set; }

    public int ItDefId { get; set; }

    public decimal ItTranId { get; set; }

    public decimal AmountEss { get; set; }

    public byte ItFlag { get; set; }

    public decimal BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal GrdId { get; set; }

    public decimal? CatId { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? SegmentId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? SubBranchId { get; set; }

    public int HasDoc { get; set; }
}
