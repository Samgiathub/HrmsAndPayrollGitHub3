using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SapGdapidatum
{
    public int Id { get; set; }

    public string? PersonnelNumberPernr { get; set; }

    public string? EndDateEndda { get; set; }

    public string? StartDateBegda { get; set; }

    public string? ActionTypeMassn { get; set; }

    public string? ReasonforActionMassg { get; set; }

    public string? EmploymentStat2 { get; set; }

    public string? CompanyCodeBukrs { get; set; }

    public string? ContractAnsvh { get; set; }

    public string? CostCenterKostl { get; set; }

    public string? FormAddrAnred { get; set; }

    public string? LastNameNachn { get; set; }

    public string? FirstNameVorna { get; set; }

    public string? TitleDesignationTitel { get; set; }

    public string? MiddleNameMidnm { get; set; }

    public string? GenderGesch { get; set; }

    public string? BirthdateGbdat { get; set; }

    public string? NationalityNatio { get; set; }

    public string? OtherNatNati2 { get; set; }

    public string? MaritalStatusFamst { get; set; }

    public string? SinceFamdt { get; set; }

    public string? NoChildAnzkd { get; set; }

    public string? BankKeyBankl { get; set; }

    public string? BankAccountBankn { get; set; }

    public string? ProbPeriodPrbzt { get; set; }

    public string? ProbationaryPeriodPrbeh { get; set; }

    public string? IdnumberUsrid0010 { get; set; }

    public string? IdnumberUsrid0035 { get; set; }

    public DateTime? Cdtm { get; set; }

    public DateTime? Udtm { get; set; }

    public string? Logdt { get; set; }

    public int? FlagDone { get; set; }
}
