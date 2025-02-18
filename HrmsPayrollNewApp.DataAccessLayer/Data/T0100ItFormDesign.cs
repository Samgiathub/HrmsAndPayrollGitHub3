using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100ItFormDesign
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public string FormatName { get; set; } = null!;

    public int RowId { get; set; }

    public string FieldName { get; set; } = null!;

    public decimal? AdId { get; set; }

    public decimal? RimbId { get; set; }

    public int DefaultDefId { get; set; }

    public byte IsTotal { get; set; }

    public int FromRowId { get; set; }

    public int ToRowId { get; set; }

    public string MultipleRowId { get; set; } = null!;

    public byte IsExempted { get; set; }

    public decimal MaxLimit { get; set; }

    public int MaxLimitCompareRowId { get; set; }

    public byte? MaxLimitCompareType { get; set; }

    public byte IsProofReq { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal? ItId { get; set; }

    public byte? FieldType { get; set; }

    public byte? IsShow { get; set; }

    public byte? ColNo { get; set; }

    public decimal? FormId { get; set; }

    public byte? ConcateSpace { get; set; }

    public byte? IsSalaryComp { get; set; }

    public int? ExemAgaintRowId { get; set; }

    public string? FinancialYear { get; set; }

    public DateTime? ForDate { get; set; }

    public bool ShowInSalarySlip { get; set; }

    public string? DisplayNameForSalaryslip { get; set; }

    public decimal Column24q { get; set; }

    public decimal NetIncomeRange { get; set; }

    public decimal FieldValue { get; set; }

    public string? TotalFormula { get; set; }

    public string? TotalFormulaActual { get; set; }

    public decimal FieldValue2 { get; set; }

    public virtual T0050AdMaster? Ad { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040FormMaster? Form { get; set; }

    public virtual T0070ItMaster? It { get; set; }
}
