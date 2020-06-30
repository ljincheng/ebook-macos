//
//  main.c
//  booktest
//
//  Created by ljc on 2018/9/14.
//  Copyright © 2018年 Bartek Fabiszewski. All rights reserved.
//

#include <stdio.h>
#include "mobi.h"
#define FULLNAME_MAX 1024

void print_meta(const MOBIData *m) {
    /* Full name stored at offset given in MOBI header */
    if (m->mh && m->mh->full_name) {
        char full_name[FULLNAME_MAX + 1];
        if (mobi_get_fullname(m, full_name, FULLNAME_MAX) == MOBI_SUCCESS) {
            printf("\nFull name: %s\n", full_name);
        }
    }
    /* Palm database header */
    if (m->ph) {
        printf("\nPalm doc header:\n");
        printf("name: %s\n", m->ph->name);
        printf("attributes: %hu\n", m->ph->attributes);
        printf("version: %hu\n", m->ph->version);
        struct tm * timeinfo = mobi_pdbtime_to_time(m->ph->ctime);
        printf("ctime: %s", asctime(timeinfo));
        timeinfo = mobi_pdbtime_to_time(m->ph->mtime);
        printf("mtime: %s", asctime(timeinfo));
        timeinfo = mobi_pdbtime_to_time(m->ph->btime);
        printf("btime: %s", asctime(timeinfo));
        printf("mod_num: %u\n", m->ph->mod_num);
        printf("appinfo_offset: %u\n", m->ph->appinfo_offset);
        printf("sortinfo_offset: %u\n", m->ph->sortinfo_offset);
        printf("type: %s\n", m->ph->type);
        printf("creator: %s\n", m->ph->creator);
        printf("uid: %u\n", m->ph->uid);
        printf("next_rec: %u\n", m->ph->next_rec);
        printf("rec_count: %u\n", m->ph->rec_count);
    }
    /* Record 0 header */
    if (m->rh) {
        printf("\nRecord 0 header:\n");
        printf("compresion type: %u\n", m->rh->compression_type);
        printf("text length: %u\n", m->rh->text_length);
        printf("text record count: %u\n", m->rh->text_record_count);
        printf("text record size: %u\n", m->rh->text_record_size);
        printf("encryption type: %u\n", m->rh->encryption_type);
        printf("unknown: %u\n", m->rh->unknown1);
    }
    /* Mobi header */
    if (m->mh) {
        printf("\nMOBI header:\n");
        printf("identifier: %s\n", m->mh->mobi_magic);
        if(m->mh->header_length) { printf("header length: %u\n", *m->mh->header_length); }
        if(m->mh->mobi_type) { printf("mobi type: %u\n", *m->mh->mobi_type); }
        if(m->mh->text_encoding) { printf("text encoding: %u\n", *m->mh->text_encoding); }
        if(m->mh->uid) { printf("unique id: %u\n", *m->mh->uid); }
        if(m->mh->version) { printf("file version: %u\n", *m->mh->version); }
        if(m->mh->orth_index) { printf("orth index: %u\n", *m->mh->orth_index); }
        if(m->mh->infl_index) { printf("infl index: %u\n", *m->mh->infl_index); }
        if(m->mh->names_index) { printf("names index: %u\n", *m->mh->names_index); }
        if(m->mh->keys_index) { printf("keys index: %u\n", *m->mh->keys_index); }
        if(m->mh->extra0_index) { printf("extra0 index: %u\n", *m->mh->extra0_index); }
        if(m->mh->extra1_index) { printf("extra1 index: %u\n", *m->mh->extra1_index); }
        if(m->mh->extra2_index) { printf("extra2 index: %u\n", *m->mh->extra2_index); }
        if(m->mh->extra3_index) { printf("extra3 index: %u\n", *m->mh->extra3_index); }
        if(m->mh->extra4_index) { printf("extra4 index: %u\n", *m->mh->extra4_index); }
        if(m->mh->extra5_index) { printf("extra5 index: %u\n", *m->mh->extra5_index); }
        if(m->mh->non_text_index) { printf("non text index: %u\n", *m->mh->non_text_index); }
        if(m->mh->full_name_offset) { printf("full name offset: %u\n", *m->mh->full_name_offset); }
        if(m->mh->full_name_length) { printf("full name length: %u\n", *m->mh->full_name_length); }
        if(m->mh->locale) {
            const char *locale_string = mobi_get_locale_string(*m->mh->locale);
            if (locale_string) {
                printf("locale: %s (%u)\n", locale_string, *m->mh->locale);
            } else {
                printf("locale: unknown (%u)\n", *m->mh->locale);
            }
        }
        if(m->mh->dict_input_lang) {
            const char *locale_string = mobi_get_locale_string(*m->mh->dict_input_lang);
            if (locale_string) {
                printf("dict input lang: %s (%u)\n", locale_string, *m->mh->dict_input_lang);
            } else {
                printf("dict input lang: unknown (%u)\n", *m->mh->dict_input_lang);
            }
        }
        if(m->mh->dict_output_lang) {
            const char *locale_string = mobi_get_locale_string(*m->mh->dict_output_lang);
            if (locale_string) {
                printf("dict output lang: %s (%u)\n", locale_string, *m->mh->dict_output_lang);
            } else {
                printf("dict output lang: unknown (%u)\n", *m->mh->dict_output_lang);
            }
        }
        if(m->mh->min_version) { printf("minimal version: %u\n", *m->mh->min_version); }
        if(m->mh->image_index) { printf("first image index: %u\n", *m->mh->image_index); }
        if(m->mh->huff_rec_index) { printf("huffman record offset: %u\n", *m->mh->huff_rec_index); }
        if(m->mh->huff_rec_count) { printf("huffman records count: %u\n", *m->mh->huff_rec_count); }
        if(m->mh->datp_rec_index) { printf("DATP record offset: %u\n", *m->mh->datp_rec_index); }
        if(m->mh->datp_rec_count) { printf("DATP records count: %u\n", *m->mh->datp_rec_count); }
        if(m->mh->exth_flags) { printf("EXTH flags: %u\n", *m->mh->exth_flags); }
        if(m->mh->unknown6) { printf("unknown: %u\n", *m->mh->unknown6); }
        if(m->mh->drm_offset) { printf("drm offset: %u\n", *m->mh->drm_offset); }
        if(m->mh->drm_count) { printf("drm count: %u\n", *m->mh->drm_count); }
        if(m->mh->drm_size) { printf("drm size: %u\n", *m->mh->drm_size); }
        if(m->mh->drm_flags) { printf("drm flags: %u\n", *m->mh->drm_flags); }
        if(m->mh->first_text_index) { printf("first text index: %u\n", *m->mh->first_text_index); }
        if(m->mh->last_text_index) { printf("last text index: %u\n", *m->mh->last_text_index); }
        if(m->mh->fdst_index) { printf("FDST offset: %u\n", *m->mh->fdst_index); }
        if(m->mh->fdst_section_count) { printf("FDST count: %u\n", *m->mh->fdst_section_count); }
        if(m->mh->fcis_index) { printf("FCIS index: %u\n", *m->mh->fcis_index); }
        if(m->mh->fcis_count) { printf("FCIS count: %u\n", *m->mh->fcis_count); }
        if(m->mh->flis_index) { printf("FLIS index: %u\n", *m->mh->flis_index); }
        if(m->mh->flis_count) { printf("FLIS count: %u\n", *m->mh->flis_count); }
        if(m->mh->unknown10) { printf("unknown: %u\n", *m->mh->unknown10); }
        if(m->mh->unknown11) { printf("unknown: %u\n", *m->mh->unknown11); }
        if(m->mh->srcs_index) { printf("SRCS index: %u\n", *m->mh->srcs_index); }
        if(m->mh->srcs_count) { printf("SRCS count: %u\n", *m->mh->srcs_count); }
        if(m->mh->unknown12) { printf("unknown: %u\n", *m->mh->unknown12); }
        if(m->mh->unknown13) { printf("unknown: %u\n", *m->mh->unknown13); }
        if(m->mh->extra_flags) { printf("extra record flags: %u\n", *m->mh->extra_flags); }
        if(m->mh->ncx_index) { printf("NCX offset: %u\n", *m->mh->ncx_index); }
        if(m->mh->unknown14) { printf("unknown: %u\n", *m->mh->unknown14); }
        if(m->mh->unknown15) { printf("unknown: %u\n", *m->mh->unknown15); }
        if(m->mh->fragment_index) { printf("fragment index: %u\n", *m->mh->fragment_index); }
        if(m->mh->skeleton_index) { printf("skeleton index: %u\n", *m->mh->skeleton_index); }
        if(m->mh->datp_index) { printf("DATP index: %u\n", *m->mh->datp_index); }
        if(m->mh->unknown16) { printf("unknown: %u\n", *m->mh->unknown16); }
        if(m->mh->guide_index) { printf("guide index: %u\n", *m->mh->guide_index); }
        if(m->mh->unknown17) { printf("unknown: %u\n", *m->mh->unknown17); }
        if(m->mh->unknown18) { printf("unknown: %u\n", *m->mh->unknown18); }
        if(m->mh->unknown19) { printf("unknown: %u\n", *m->mh->unknown19); }
        if(m->mh->unknown20) { printf("unknown: %u\n", *m->mh->unknown20); }
    }
}



int main() {
    // insert code here...
    printf("Hello, World!\n");
 //   print_extended_meta_opt = 1;
    // int ret = 0;
   // loadfilename("/workspace/ebook/bookfere/zh/传记/奥威尔传：冷峻的良心.azw3");

    MOBIData *m = mobi_init();
    if (m == NULL) {
        return 1;
    }
    
    FILE *file = fopen("/workspace/ebook/bookfere/zh/传记/奥威尔传：冷峻的良心.azw3", "rb");
    if (file == NULL) {
        mobi_free(m);
        return 1;
    }
    
    MOBI_RET mobi_ret = mobi_load_file(m, file);
    fclose(file);
    if (mobi_ret != MOBI_SUCCESS) {
        mobi_free(m);
        return 1;
    }
    
    MOBIRawml *rawml = mobi_init_rawml(m);
    if (rawml == NULL) {
        mobi_free(m);
        return 1;
    }
    
    mobi_ret = mobi_parse_rawml(rawml, m);
    if (mobi_ret != MOBI_SUCCESS) {
        mobi_free(m);
        mobi_free_rawml(rawml);
        return 1;
    }
    print_meta(m);
    
    mobi_free_rawml(rawml);
    
    
    mobi_free(m);
    
    
    
    return 0;
}
