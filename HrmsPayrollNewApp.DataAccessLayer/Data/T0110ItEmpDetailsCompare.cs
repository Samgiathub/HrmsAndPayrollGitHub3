using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110ItEmpDetailsCompare
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public string? FinancialYear { get; set; }

    public decimal? ItId { get; set; }

    public DateTime? Date { get; set; }

    public DateTime? SystemDate { get; set; }

    public DateTime? ChangeDate { get; set; }

    public decimal? Amount { get; set; }

    public string? Detail1 { get; set; }

    public string? Detail2 { get; set; }

    public string? Detail3 { get; set; }

    public string? Comments { get; set; }

    public string? FileName { get; set; }

    public decimal? Child1 { get; set; }

    public decimal? Child2 { get; set; }

    public byte? Medical80Ddbtype { get; set; }

    public string? FieldName { get; set; }

    public string? IsCompareFlag { get; set; }
}
